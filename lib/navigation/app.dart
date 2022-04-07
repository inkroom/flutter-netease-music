import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/desktop/home_window.dart';
import 'package:quiet/providers/navigator_provider.dart';
import 'package:window_manager/window_manager.dart';

import '../providers/settings_provider.dart';
import 'mobile/mobile_window.dart';

class QuietApp extends ConsumerWidget {
  const QuietApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    NetworkSingleton().setMode(ref.read(settingStateProvider).networkMode);
    final Widget home;
    final platform = ref.watch(debugNavigatorPlatformProvider);
    switch (platform) {
      case NavigationPlatform.desktop:
        home = const HomeWindow();
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

/// 开启时弹窗，目前仅在启动第二个实例时调用

class AlertApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
      home: Alert(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 必须要套个娃，要不然没法使用国际化代码
class Alert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.current.alertAppLaunched),
      content: Text(S.current.alertAppLaunched),
      actions: [
        TextButton(
            onPressed: () {
              exit(0);
            },
            child: Text(S.current.alterActionClose))
      ],
    );
  }
}
