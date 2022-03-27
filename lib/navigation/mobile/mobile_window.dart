import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/providers/settings_provider.dart';
import 'package:quiet/repository.dart';
import 'package:update_app/update_app.dart';
import 'package:window_manager/window_manager.dart';

import '../../providers/navigator_provider.dart';
import '../common/navigator.dart';
import 'widgets/bottom_bar.dart';

class MobileWindow extends StatelessWidget {
  const MobileWindow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform.isDesktop()) {
      return const _MobileWindowOnDesktopWrapper(
        child: _MobileWindowLayout(),
      );
    }

    /// 当前只支持android平台自动更新
    if (Platform.isAndroid && NetworkSingleton.instance.allowNetwork()) {
      networkRepository?.checkUpdate().then((value) {
        if (value != null && value['versionName'] != null) {
          PackageInfo.fromPlatform().then((info) {
            if (info.version != value['versionName']) {
              toast(context.strings.updateTip(value['versionName']));
              return UpdateApp.updateApp(
                  url: "http://minio.bcyunqian.com/temp/${value['outputFile']}",
                  appleId: "375380948",
                  title: context.strings.updateTitle(info.appName),
                  description: context.strings.updateTip(value['versionName']));
            }
            return -2;
          }).then((value) {
            if (value == -1) {
              toast('更新失败');
            }
          });
        }
      }).catchError((error) {
        // showDialog(context: context, builder: (context) => Text('检查失败 $error'));
        toast('检查失败 $error');
      });
    }

    return const _MobileWindowLayout();
  }
}

class _MobileWindowLayout extends StatelessWidget {
  const _MobileWindowLayout({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.background,
      child: Container(
        foregroundDecoration: const BoxDecoration(
            image: DecorationImage(
                fit: BoxFit.cover,
                opacity: 0.2,
                image: AssetImage("assets/mobile_bg.jpg"))),
        child: const AnimatedAppBottomBar(
          child: AppNavigator(),
        ),
      ),
    );
  }
}

// show mobile window on desktop. (for debug)
class _MobileWindowOnDesktopWrapper extends HookConsumerWidget {
  const _MobileWindowOnDesktopWrapper({Key? key, required this.child})
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useMemoized(() {
      WindowManager.instance.setMinimumSize(Size.zero);
      WindowManager.instance.setSize(const Size(375, 667 + 40), animate: true);
    });
    return Column(
      children: [
        Material(
          child: SizedBox(
            height: 40,
            child: Stack(
              children: [
                Row(
                  children: [
                    if (defaultTargetPlatform == TargetPlatform.macOS)
                      const SizedBox(width: 40),
                    BackButton(
                      onPressed: () {
                        ref.read(navigatorProvider.notifier).back();
                      },
                    ),
                  ],
                ),
                const Center(child: Text('mobile')),
              ],
            ),
          ),
        ),
        Expanded(child: AspectRatio(aspectRatio: 9 / 16, child: child)),
      ],
    );
  }
}
