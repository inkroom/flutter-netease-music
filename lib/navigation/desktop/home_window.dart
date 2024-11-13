import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart' hide MenuItem;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/utils/single.dart';
import 'package:tray_manager/tray_manager.dart' as tray;
import 'package:quiet/navigation/common/update_dialog.dart';
import 'package:quiet/providers/player_provider.dart';

import 'package:window_manager/window_manager.dart';
import '../../providers/navigator_provider.dart';
import '../common/navigation_target.dart';
import '../common/navigator.dart';
import 'bottom_player_bar.dart';
import 'header_bar.dart';
import 'navigation_side_bar.dart';
import 'player/page_playing.dart';
import 'player/page_playing_list.dart';
import 'widgets/hotkeys.dart';
import 'widgets/windows_task_bar.dart';
import 'package:quiet/extension.dart';

class HomeWindow extends ConsumerStatefulWidget {
  const HomeWindow({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeWindowState();
}

class _HomeWindowState extends ConsumerState<HomeWindow>
    with WindowListener, tray.TrayListener {
  @override
  void initState() {
    super.initState();
    updateApp(context);

    windowManager.addListener(this);

    _initTray();
  }

  void _initTray() async {
    tray.trayManager.addListener(this);
    await tray.trayManager.setIcon(
        Platform.isWindows ? 'assets/icons/logo.ico' : 'assets/logo.png');

    _initTrayMenu();
  }

  void _initTrayMenu() async {
    tray.Menu menu = tray.Menu(items: [
      if (ref.read(playerStateProvider).isPlaying)
        tray.MenuItem(
          // 这里不能直接用 context.strings
          label: S.current.pause,
          key: 'pause',
        ),
      if (!ref.read(playerStateProvider).isPlaying)
        tray.MenuItem(
          // 这里不能直接用 context.strings
          label: S.current.play,
          key: 'play',
        ),
      tray.MenuItem(
        // 这里不能直接用 context.strings
        label: S.current.skipToNext,
        key: 'next',
      ),
      tray.MenuItem.separator(),
      tray.MenuItem(
          // 这里不能直接用 context.strings
          label: S.current.trayItemShow,
          key: 'show'),
      tray.MenuItem(
        label: S.current.trayItemHide,
        key: 'hide',
      ),
      tray.MenuItem(
        label: S.current.trayItemExit,
        key: 'exit',
      ),
    ]);
    await tray.trayManager.setContextMenu(menu);
  }

  @override
  void onTrayMenuItemClick(tray.MenuItem menuItem) {
    switch (menuItem.key) {
      case 'play':
        ref.read(playerProvider).play();
        break;
      case 'pause':
        ref.read(playerProvider).pause();
        break;
      case 'next':
        ref.read(playerProvider).skipToNext();
        break;
      case 'show':
        _show();
        break;
      case 'hide':
        windowManager.hide();
        break;
      case 'exit':
        // 先把窗口隐藏再慢慢关闭，避免可能出现程序窗口半天才消失问题
        windowManager
            .hide()
            .then((value) => tray.trayManager.destroy())
            .then((value) => windowManager.setPreventClose(false))
            .then((value) {
          SingleApp.instance.release();
          if (Platform.isLinux) {
            //因为destroy方法不支持linux系统
            exit(0);
          } else {
            windowManager.destroy();
          }
        });
        break;
    }
  }

  @override
  void onTrayIconMouseDown() async {
    super.onTrayIconMouseDown();
    _show();
  }

  @override
  void onTrayIconRightMouseDown() {
    super.onTrayIconRightMouseDown();
    _initTrayMenu();
    tray.trayManager.popUpContextMenu();
  }

  void _show() {
    windowManager.show();
    // 手动触发重绘，避免只显示边框
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    tray.trayManager.removeListener(this);
    windowManager.removeListener(this);
  }

  @override
  void onWindowClose() {
    windowManager.isPreventClose().then((value) {
      if (value) {
        windowManager.hide();
      } else {
        tray.trayManager.destroy();
        exit(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      foregroundDecoration: const BoxDecoration(
          image: DecorationImage(
              fit: BoxFit.cover,
              opacity: 0.2,
              image: AssetImage('assets/desktop_bg.jpg'))),
      child: const WindowsTaskBar(child: _WindowLayout()),
    );
  }
}

class _WindowLayout extends StatelessWidget {
  const _WindowLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: _OverflowBox(
        child: Material(
          child: Column(
            children: const [
              HeaderBar(),
              _ContentLayout(),
              BottomPlayerBar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentLayout extends StatelessWidget {
  const _ContentLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DesktopPlayingPageContainer(
        child: Row(
          children: const [
            SizedBox(width: 200, child: NavigationSideBar()),
            Expanded(
              child: ClipRect(
                child: AppNavigator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverflowBox extends StatelessWidget {
  const _OverflowBox({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxHeight = math.max(constraints.maxHeight, 640.0);
      final maxWidth = math.max(constraints.maxWidth, 800.0);
      return OverflowBox(
        minHeight: 640,
        maxHeight: maxHeight,
        minWidth: 800,
        maxWidth: maxWidth,
        child: child,
      );
    });
  }
}

class DesktopPlayingPageContainer extends ConsumerWidget {
  const DesktopPlayingPageContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingPage = ref.watch(navigatorProvider
        .select((value) => value.current is NavigationTargetPlaying));
    final showPlayingList = ref.watch(showPlayingListProvider);
    return Stack(
      children: [
        child,
        ClipRect(child: _SlideAnimatedPlayingPage(visible: playingPage)),
        Align(
          alignment: Alignment.centerRight,
          child: ClipRect(
            child: SizedBox(
              width: 400,
              child: _SlideAnimatedPlayingListOverlay(
                visible: showPlayingList,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SlideAnimatedPlayingListOverlay extends HookWidget {
  const _SlideAnimatedPlayingListOverlay({
    Key? key,
    required this.visible,
  }) : super(key: key);

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 300),
      initialValue: visible ? 1.0 : 0.0,
    );
    useEffect(() {
      if (visible) {
        controller.forward();
      } else {
        controller.reverse();
      }
    }, [visible]);

    final animation = useMemoized(() {
      final tween = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      );
      return tween.animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }, [controller]);
    final offset = useAnimation(animation);

    if (controller.isDismissed) {
      return const SizedBox.shrink();
    }
    return FractionalTranslation(
      translation: offset,
      child: const PagePlayingList(),
    );
  }
}

class _SlideAnimatedPlayingPage extends HookWidget {
  const _SlideAnimatedPlayingPage({
    Key? key,
    required this.visible,
  }) : super(key: key);

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 300),
      initialValue: visible ? 1.0 : 0.0,
    );
    useEffect(() {
      if (visible) {
        controller.forward();
      } else {
        controller.reverse();
      }
    }, [visible]);

    final animation = useMemoized(() {
      final tween = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      );
      return tween.animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );
    }, [controller]);
    final offset = useAnimation(animation);

    if (controller.isDismissed) {
      return const SizedBox.shrink();
    }
    return FractionalTranslation(
      translation: offset,
      child: const PagePlaying(),
    );
  }
}
