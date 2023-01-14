import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quiet/repository/setting.dart';

final settingStateProvider =
    StateNotifierProvider<Settings, SettingState>((ref) {
  return Settings();
});

final versionStateProvider =
    StateNotifierProvider<VersionNotify, VersionState>((ref) {
  return VersionNotify();
});

class VersionState with EquatableMixin {
  VersionState({this.info});

  PackageInfo? info;

  @override
  List<Object?> get props => [info];
}

class VersionNotify extends StateNotifier<VersionState> {
  VersionNotify() : super(VersionState());

  void setInfo(PackageInfo info) {
    state = VersionState(info: info);
  }
}

class SettingState with EquatableMixin {
  const SettingState({
    required this.networkMode,
    required this.themeMode,
    required this.skipWelcomePage,
    required this.skipAccompaniment,
    required this.savePath,
  });

  factory SettingState.fromPreference(SettingKey preference) {
    log("保存位置= ${preference.savePath}");
    return SettingState(
      savePath: preference.savePath,
      networkMode: preference.networkMode,
      themeMode: preference.themeMode,
      skipWelcomePage: false,
      skipAccompaniment: preference.skipAccompaniment,
    );
  }

  final String savePath;
  final NetworkMode networkMode;
  final ThemeMode themeMode;
  final bool skipWelcomePage;
  final bool skipAccompaniment;

  @override
  List<Object> get props => [
        themeMode,
        skipWelcomePage,
        skipAccompaniment,
        networkMode,
        savePath,
      ];

  SettingState copyWith({
    String? savePath,
    NetworkMode? networkMode,
    ThemeMode? themeMode,
    bool? skipWelcomePage,
    bool? skipAccompaniment,
  }) =>
      SettingState(
        savePath: savePath ?? this.savePath,
        networkMode: networkMode ?? this.networkMode,
        themeMode: themeMode ?? this.themeMode,
        skipWelcomePage: skipWelcomePage ?? this.skipWelcomePage,
        skipAccompaniment: skipAccompaniment ?? this.skipAccompaniment,
      );
}

class Settings extends StateNotifier<SettingState> {
  Settings()
      : super(const SettingState(
          networkMode: NetworkMode.NONE,
          themeMode: ThemeMode.system,
          skipWelcomePage: true,
          skipAccompaniment: false,
          savePath: '',
        ));

  late final SettingKey _preferences;

  void attachPreference(SettingKey preference) {
    _preferences = preference;
    state = SettingState.fromPreference(preference);
    NetworkSingleton.instance.setMode(state.networkMode);
  }

  void setThemeMode(ThemeMode themeMode) {
    _preferences.themeMode = themeMode;
    state = state.copyWith(themeMode: themeMode);
  }

  void setSavePath(String path) {
    _preferences.savePath = path;
    state = state.copyWith(savePath: path);
  }

  void setNetworkMode(NetworkMode networkMode) {
    NetworkSingleton().setMode(networkMode);
    NetworkSingleton().updateNetwork();
    _preferences.networkMode = networkMode;
    state = state.copyWith(networkMode: networkMode);
  }

  void setSkipWelcomePage() {
    // _preferences.;
    state = state.copyWith(skipWelcomePage: false);
  }

  void setSkipAccompaniment({required bool skip}) {
    _preferences.skipAccompaniment = skip;
    state = state.copyWith(skipAccompaniment: skip);
  }
}

/// 用于实现网络控制的单例模式
class NetworkSingleton {
  final f = Connectivity();

  NetworkSingleton._internal() {
    f.checkConnectivity().then((value) {
      _now = value;
    }).catchError((onError) {
      log('网络状态error,$onError');
    });
    f.onConnectivityChanged.listen((event) {
      log('网络变化=$event');
      _now = event;
    });
    // 初始化
    _mode = NetworkMode.NONE;
  }

  // 工厂模式
  factory NetworkSingleton() => _getInstance();

  static NetworkSingleton get instance => _getInstance();
  static NetworkSingleton _instance = NetworkSingleton._internal();

  NetworkMode _mode = NetworkMode.NONE;

  setMode(NetworkMode mode) {
    _mode = mode;
  }

  NetworkMode mode() => _mode;
  ConnectivityResult? _now;

  static NetworkSingleton _getInstance() {
    return _instance;
  }

  /// 主动更新网络，用于部分情况下监听网络变化失效问题
  void updateNetwork() {
    f.checkConnectivity().then((value) {
      _now = value;
    }).catchError((onError) {
      log('网络状态error,$onError');
    });
  }

  /// 判断是否运行联网
  bool allowNetwork() {
    log('当前网络=$_now 设置=$_mode');
    if (_mode == NetworkMode.NONE) {
      return false;
    } else if (_mode == NetworkMode.MOBILE) {
      return _now == ConnectivityResult.mobile || _now == ConnectivityResult.wifi ||
          _now == ConnectivityResult.ethernet;
    } else if (_mode == NetworkMode.WIFI) {
      return _now == ConnectivityResult.wifi ||
          _now == ConnectivityResult.ethernet;
    }
    return true;
  }
}
