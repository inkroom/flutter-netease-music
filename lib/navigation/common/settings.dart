import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/repository/setting.dart';

import '../../providers/navigator_provider.dart';
import '../../providers/settings_provider.dart';

class ThemeSwitchRadios extends ConsumerWidget {
  const ThemeSwitchRadios({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      settingStateProvider.select((value) => value.themeMode),
    );
    final notifier = ref.read(settingStateProvider.notifier);
    return Column(
      children: [
        RadioListTile<ThemeMode>(
          onChanged: (mode) => notifier.setThemeMode(mode!),
          groupValue: themeMode,
          value: ThemeMode.system,
          title: Text(context.strings.themeAuto),
        ),
        RadioListTile<ThemeMode>(
          onChanged: (mode) => notifier.setThemeMode(mode!),
          groupValue: themeMode,
          value: ThemeMode.light,
          title: Text(context.strings.themeLight),
        ),
        RadioListTile<ThemeMode>(
          onChanged: (mode) => notifier.setThemeMode(mode!),
          groupValue: themeMode,
          value: ThemeMode.dark,
          title: Text(context.strings.themeDark),
        )
      ],
    );
  }
}

class DebugPlatformNavigationRadios extends ConsumerWidget {
  const DebugPlatformNavigationRadios({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(debugNavigatorPlatformProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<NavigationPlatform>(
          onChanged: (mode) =>
              ref.read(debugNavigatorPlatformProvider.notifier).state = mode!,
          groupValue: platform,
          value: NavigationPlatform.desktop,
          title: Text(NavigationPlatform.desktop.name),
        ),
        RadioListTile<NavigationPlatform>(
          onChanged: (mode) =>
              ref.read(debugNavigatorPlatformProvider.notifier).state = mode!,
          groupValue: platform,
          value: NavigationPlatform.mobile,
          title: Text(NavigationPlatform.mobile.name),
        ),
      ],
    );
  }
}

// 启动播放设置项
class AutoPlayOnStart extends ConsumerWidget {
  const AutoPlayOnStart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckboxListTile(
      value: ref.watch(
        settingStateProvider.select((value) => value.autoPlayOnStart),
      ),
      onChanged: (value) => ref
          .read(settingStateProvider.notifier)
          .setAutoPlayOnStart(value: value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(context.strings.autoPlayOnStart),
    );
  }
}

class SkipAccompanimentCheckBox extends ConsumerWidget {
  const SkipAccompanimentCheckBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckboxListTile(
      value: ref.watch(
        settingStateProvider.select((value) => value.skipAccompaniment),
      ),
      onChanged: (value) => ref
          .read(settingStateProvider.notifier)
          .setSkipAccompaniment(skip: value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(context.strings.skipAccompaniment),
    );
  }
}

/// 切换网络设置
class NetworkSwitchRadios extends ConsumerWidget {
  const NetworkSwitchRadios({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkMode = ref.watch(
      settingStateProvider.select((value) => value.networkMode),
    );
    final notifier = ref.read(settingStateProvider.notifier);
    return Column(
      children: [
        RadioListTile<NetworkMode>(
          onChanged: (mode) => notifier.setNetworkMode(mode!),
          groupValue: networkMode,
          value: NetworkMode.WIFI,
          title: Text(context.strings.settingItemOnlyWIFI),
        ),
        RadioListTile<NetworkMode>(
          onChanged: (mode) => notifier.setNetworkMode(mode!),
          groupValue: networkMode,
          value: NetworkMode.MOBILE,
          title: Text(context.strings.settingItemOnlyMobile),
        ),
        RadioListTile<NetworkMode>(
          onChanged: (mode) => notifier.setNetworkMode(mode!),
          groupValue: networkMode,
          value: NetworkMode.NONE,
          title: Text(context.strings.settingItemNoNetwork),
        )
      ],
    );
  }
}
