import 'dart:async';
import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/navigation/app.dart';
import 'package:quiet/pages/splash/page_splash.dart';
import 'package:quiet/repository.dart';
import 'package:window_manager/window_manager.dart';

import 'utils/system/system_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadFallbackFonts();
  NetworkRepository.initialize();
  DartVLC.initialize();
  _initialDesktop();
  runZonedGuarded(() {
    runApp(ProviderScope(
      child: PageSplash(
        futures: [
        ],
        builder: (BuildContext context, List<dynamic> data) {
          return MyApp(
          );
        },
      ),
    ));
  }, (error, stack) {
    debugPrint('uncaught error : $error $stack');
  });
}

void _initialDesktop() async {
  if (!(Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    return;
  }
  await WindowManager.instance.ensureInitialized();
  if (Platform.isWindows) {
    // only Windows need this.
    WindowManager.instance.setMinimumSize(const Size(960, 720));
    // setResizable windows下没有生效，就直接限制最大尺寸;其他平台未测试
    WindowManager.instance.setMaximumSize(const Size(960, 720));
    WindowManager.instance.setResizable(false);
  }

  assert(() {
    scheduleMicrotask(() async {
      final size = await WindowManager.instance.getSize();
      WindowManager.instance.setResizable(false);
      if (size.width < 960 || size.height < 720) {
        WindowManager.instance.setSize(const Size(960, 720), animate: true);
      }
    });

    return true;
  }());
}

/// The entry of dart background service
/// NOTE: this method will be invoked by native (Android/iOS)
// @pragma('vm:entry-point') // avoid Tree Shaking
// void playerBackgroundService() {
//   WidgetsFlutterBinding.ensureInitialized();
//   // 获取播放地址需要使用云音乐 API, 所以需要为此 isolate 初始化一个 repository.
//   NetworkRepository.initialize();
//   runMobileBackgroundService();
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const OverlaySupport(
      child: QuietApp(),
    );
  }
}
