import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/desktop/home_window.dart';
import 'package:quiet/providers/navigator_provider.dart';

import '../providers/settings_provider.dart';
import 'mobile/mobile_window.dart';

class QuietApp extends ConsumerWidget {
  const QuietApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIXME 网络变化监听还是有问题，搜索页面总是跟随设置，但是发现、音乐库、我的页面状态有问题，但是还没有确定复现步骤
    final networkMode = ref.watch(
      settingStateProvider.select((value) => value.networkMode),
    );
    NetworkSingleton().setMode(networkMode);
    final Widget home;
    final platform = ref.watch(debugNavigatorPlatformProvider);
    switch (platform) {
      case NavigationPlatform.desktop:
        home = const MobileWindow();
        break;
      case NavigationPlatform.mobile:
        home = const MobileWindow();
        break;
    }
    return MaterialApp(
      title: 'Quiet',
      supportedLocales: const [Locale("en"), Locale("zh")],
      localizationsDelegates: const [
        S.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: lightTheme,
      darkTheme: quietDarkTheme,
      themeMode: ref.watch(
        settingStateProvider.select((value) => value.themeMode),
      ),
      home: home,
      debugShowCheckedModeBanner: false,
    );
  }
}
