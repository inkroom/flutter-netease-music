import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/app.dart';
import 'package:quiet/pages/splash/page_splash.dart';
import 'package:quiet/providers/settings_provider.dart';
import 'package:quiet/repository.dart';
import 'package:quiet/utils/single.dart';
import 'package:window_manager/window_manager.dart';

import 'utils/system/system_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadFallbackFonts();
  NetworkRepository.initialize();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    /// 开始获取锁
    SingleApp.instance.lock().then((value) {
      if (value) {
        // DartVLC.initialize();
        _initialDesktop();
        runZonedGuarded(() {
          runApp(ProviderScope(
            child: PageSplash(
              futures: [NetworkSingleton().updateNetwork()],
              builder: (BuildContext context, List<dynamic> data) {
                return const MyApp();
              },
            ),
          ));
        }, (error, stack) {
          debugPrint('uncaught error : $error $stack');
        });
      } else {
        //获取失败
        runApp(AlertApp());
      }
    });
  } else {
    runZonedGuarded(() {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      // SystemChrome.setPreferredOrientations([ 	 //强制横屏
      //   DeviceOrientation.landscapeLeft,
      //   DeviceOrientation.landscapeRight
      // ]);
      runApp(ProviderScope(
        child: PageSplash(
          futures: [NetworkSingleton().updateNetwork()],
          builder: (BuildContext context, List<dynamic> data) {
            return const MyApp();
          },
        ),
      ));
    }, (error, stack) {
      debugPrint('uncaught error : $error $stack');
    });
  }
}

void _initialDesktop() async {
  await WindowManager.instance.ensureInitialized();
  // only Windows need this.
  // WindowManager.instance.setPosition(Offset(2100,300));
  WindowManager.instance.setMinimumSize(const Size(960, 720));
  // setResizable windows下没有生效，就直接限制最大尺寸;其他平台未测试
  WindowManager.instance.setMaximumSize(const Size(960, 720));
  WindowManager.instance.setResizable(false);
  await WindowManager.instance.setPreventClose(true);

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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: const QuietApp(),
        position:
            const ToastPosition(align: Alignment.bottomCenter, offset: -100.0),
        radius: 5,
        textStyle: lightTheme.textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ));
  }
}
