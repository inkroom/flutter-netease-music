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
  }

  void setThemeMode(ThemeMode themeMode) {
    _preferences.setInt(_keyThemeMode, themeMode.index);
    state = state.copyWith(themeMode: themeMode);
  }

  void setNetworkMode(NetworkMode networkMode){
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
