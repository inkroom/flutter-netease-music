import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefix = 'quiet:settings:';
enum NetworkMode {
  /// 仅使用wifi
  WIFI,

  /// wifi+流量
  MOBILE,

  /// 不联网
  NONE
}

class SettingKey {
  SettingKey._internal() {
    // SharedPreferences.getInstance().then((value) => preferences = value);
  }

  static Future<SettingKey> init() {
    return SharedPreferences.getInstance().then((value) {
      SettingKey.instance.preferences = value;
      return SettingKey.instance;
    });
  }

  static SettingKey get instance => _getInstance();
  static SettingKey _instance = SettingKey._internal();

  static SettingKey _getInstance() {
    return _instance;
  }

  final String _keyThemeMode = '$_prefix:themeMode';

  final String _keyNetworkMode = '$_prefix:networkMode';

  final String _keySkipWelcomePage = '$_prefix:skipWelcomePage';

  final String _keySavePath = '$_prefix:savePath';

  SharedPreferences? preferences;

  NetworkMode get networkMode {
    final mode = preferences?.getInt(_keyNetworkMode);
    if (mode != null) {
      return NetworkMode.values[mode.clamp(0, NetworkMode.values.length - 1)];
    }
    return NetworkMode.NONE;
  }

  set networkMode(NetworkMode mode) {
    preferences?.setInt(_keyNetworkMode, mode.index);
  }

  ThemeMode get themeMode {
    final mode = preferences?.getInt(_keyThemeMode);
    if (mode != null) {
      return ThemeMode.values[mode.clamp(0, ThemeMode.values.length - 1)];
    }
    return ThemeMode.system;
  }

  set themeMode(ThemeMode mode) {
    preferences?.setInt(_keyThemeMode, mode.index);
  }

  bool get skipAccompaniment =>
      preferences?.getBool(_keySkipWelcomePage) ?? false;

  set skipAccompaniment(bool value) {
    preferences?.setBool(_keySkipWelcomePage, value);
  }

  // 此处的默认值不重要，因为程序启动之后会自动写入默认值，保证此处的默认值不会被返回
  String get savePath {
    return preferences?.getString(_keySavePath) ?? '';
  }

  set savePath(String value) {
    preferences?.setString(_keySavePath, value);
  }
}
