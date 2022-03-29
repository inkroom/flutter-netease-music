import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefix = 'quiet:settings:';

const String _keyThemeMode = '$_prefix:themeMode';

const String _keyNetworkMode = '$_prefix:networkMode';

const String _keyCopyright = '$_prefix:copyright';

const String _keySkipWelcomePage = '$_prefix:skipWelcomePage';

final settingStateProvider =
    StateNotifierProvider<Settings, SettingState>((ref) {
  return Settings();
});

enum NetworkMode {
  /// 仅使用wifi
  WIFI,

  /// wifi+流量
  MOBILE,

  /// 不联网
  NONE
}

class SettingState with EquatableMixin {
  const SettingState({
    required this.networkMode,
    required this.themeMode,
    required this.skipWelcomePage,
    required this.copyright,
    required this.skipAccompaniment,
  });

  factory SettingState.fromPreference(SharedPreferences preference) {
    final mode = preference.getInt(_keyThemeMode) ?? 0;
    final networkMode =
        preference.getInt(_keyNetworkMode) ?? NetworkMode.NONE.index;
    assert(mode >= 0 && mode < ThemeMode.values.length, 'invalid theme mode');
    return SettingState(
      networkMode: NetworkMode
          .values[networkMode.clamp(0, NetworkMode.values.length - 1)],
      themeMode: ThemeMode.values[mode.clamp(0, ThemeMode.values.length - 1)],
      skipWelcomePage: preference.getBool(_keySkipWelcomePage) ?? false,
      copyright: preference.getBool(_keyCopyright) ?? true,
      skipAccompaniment:
          preference.getBool('$_prefix:skipAccompaniment') ?? false,
    );
  }

  final NetworkMode networkMode;
  final ThemeMode themeMode;
  final bool skipWelcomePage;
  final bool copyright;
  final bool skipAccompaniment;

  @override
  List<Object> get props => [
        themeMode,
        skipWelcomePage,
        copyright,
        skipAccompaniment,
        networkMode,
      ];

  SettingState copyWith({
    NetworkMode? networkMode,
    ThemeMode? themeMode,
    bool? skipWelcomePage,
    bool? copyright,
    bool? skipAccompaniment,
  }) =>
      SettingState(
        networkMode: networkMode ?? this.networkMode,
        themeMode: themeMode ?? this.themeMode,
        skipWelcomePage: skipWelcomePage ?? this.skipWelcomePage,
        copyright: copyright ?? this.copyright,
        skipAccompaniment: skipAccompaniment ?? this.skipAccompaniment,
      );
}

class Settings extends StateNotifier<SettingState> {
  Settings()
      : super(const SettingState(
          networkMode: NetworkMode.NONE,
          themeMode: ThemeMode.system,
          copyright: false,
          skipWelcomePage: true,
          skipAccompaniment: false,
        ));

  late final SharedPreferences _preferences;

  void attachPreference(SharedPreferences preference) {
    _preferences = preference;
    state = SettingState.fromPreference(preference);
    NetworkSingleton.instance.setMode(state.networkMode);
  }

  void setThemeMode(ThemeMode themeMode) {
    _preferences.setInt(_keyThemeMode, themeMode.index);
    state = state.copyWith(themeMode: themeMode);
  }

  void setNetworkMode(NetworkMode networkMode) {
    NetworkSingleton().setMode(networkMode);
    NetworkSingleton().updateNetwork();
    _preferences.setInt(_keyNetworkMode, networkMode.index);
    state = state.copyWith(networkMode: networkMode);
  }

  void setSkipWelcomePage() {
    _preferences.setBool(_keySkipWelcomePage, true);
    state = state.copyWith(skipWelcomePage: true);
  }

  void setSkipAccompaniment({required bool skip}) {
    _preferences.setBool('$_prefix:skipAccompaniment', skip);
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
      return _now == ConnectivityResult.mobile;
    } else if (_mode == NetworkMode.WIFI) {
      return _now == ConnectivityResult.wifi ||
          _now == ConnectivityResult.ethernet;
    }
    return true;
  }
}
