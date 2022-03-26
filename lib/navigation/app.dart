import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/desktop/home_window.dart';
import 'package:quiet/providers/navigator_provider.dart';
import 'package:quiet/repository.dart';
import 'package:update_app/update_app.dart';
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

    /// 当前只支持android平台自动更新
    if (Platform.isAndroid) {
      networkRepository?.checkUpdate().then((value) {
        if (value != null) {
          toast('当前版本落后，将更新到新版本');
          UpdateApp.updateApp(
                  url:
                      "http://minio.bcyunqian.com/temp/app-v$value-release.apk",
                  appleId: "375380948",
                  title: "quiet正在更新",
                  description: "当前版本落后，将更新到新版本")
              .then((value) {
            if (value == -1) {
              toast('app更新失败');
            }
          });
        }
      });
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
