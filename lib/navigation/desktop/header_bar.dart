import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/common/search_origin.dart';
import 'package:quiet/providers/navigator_provider.dart';
import 'package:quiet/providers/search_provider.dart';
import 'package:quiet/repository.dart';
import 'package:window_manager/window_manager.dart';

import '../common/navigation_target.dart';
import 'widgets/caption_icons.dart';

class HeaderBar extends StatelessWidget {
  const HeaderBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.background,
      elevation: 10,
      child: Padding(
        padding: EdgeInsets.only(
          top: defaultTargetPlatform == TargetPlatform.macOS ? 20 : 4,
          bottom: 4,
        ),
        child: SizedBox(
          height: 42,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 180, child: _HeaderNavigationButtons()),
              const Expanded(child: _MoveWindow.expand()),
              SizedBox(
                child: SearchOrigin(),
                width: MusicApiContainer.instance.list.length * 80,
              ),
              const _SearchBar(),
              const SizedBox(width: 10, child: _MoveWindow.expand()),
              const _SettingButton(),
              const SizedBox(width: 20, child: _MoveWindow.expand()),
              if (defaultTargetPlatform == TargetPlatform.windows)
                const _WindowCaptionButtonGroup(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderNavigationButtons extends ConsumerWidget {
  const _HeaderNavigationButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigatorState = ref.watch(navigatorProvider);
    final navigator = ref.read(navigatorProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Expanded(child: _MoveWindow.expand()),
        IconButton(
          splashRadius: 20,
          mouseCursor: navigatorState.canBack
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          iconSize: 24,
          onPressed: navigatorState.canBack ? navigator.back : null,
          icon: const Icon(Icons.navigate_before),
        ),
        IconButton(
          splashRadius: 20,
          mouseCursor: navigatorState.canForward
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onPressed: navigatorState.canForward ? navigator.forward : null,
          iconSize: 24,
          icon: const Icon(Icons.navigate_next),
        ),
      ],
    );
  }
}

class _SearchBar extends HookConsumerWidget {
  const _SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textEditingController = useTextEditingController();
    return SizedBox(
      height: 24,
      width: 200,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: context.colorScheme.onBackground.withOpacity(0.5),
            width: 1,
          ),
          color: context.colorScheme.surface,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 10, child: _MoveWindow.expand()),
            const Icon(Icons.search, size: 16),
            const SizedBox(width: 4, child: _MoveWindow.expand()),
            Expanded(
              child: TextField(
                  cursorHeight: 12,
                  controller: textEditingController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration.collapsed(
                    hintText: context.strings.search,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: context.textTheme.caption!.color,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      SearchQueryState v = ref.read(searchMusicQueryProvider);

                      ref
                          .read(searchMusicProvider(
                                  value.trim() + v.origin.toString())
                              .notifier)
                          .search(value.trim(), origin: v.origin);

                      ref
                          .read(searchMusicQueryProvider.notifier)
                          .setQuery(value.trim(), v.origin);

                      ref.read(navigatorProvider.notifier).navigate(
                          NavigationTargetSearchMusicResult(
                              value.trim(), v.origin));
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingButton extends ConsumerWidget {
  const _SettingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(navigatorProvider
        .select((value) => value.current is NavigationTargetSettings));
    return IconButton(
      icon: const Icon(Icons.settings),
      iconSize: 20,
      splashRadius: 20,
      color: selected ? context.colorScheme.primary : null,
      onPressed: () => ref
          .read(navigatorProvider.notifier)
          .navigate(NavigationTargetSettings()),
    );
  }
}

class _WindowCaptionButtonGroup extends HookWidget {
  const _WindowCaptionButtonGroup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _WindowButton(
        icon: MinimizeIcon(color: context.iconTheme.color!),
        onTap: () {
          WindowManager.instance.minimize();
        },
      ),
      _WindowButton(
        icon: CloseIcon(color: context.iconTheme.color!),
        onTap: () {
          WindowManager.instance.close();
        },
      ),
    ]);
  }
}

class _WindowButton extends StatelessWidget {
  const _WindowButton({
    Key? key,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  final Widget icon;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      iconSize: 24,
      splashRadius: 20,
      onPressed: onTap,
    );
  }
}

class _MoveWindow extends StatelessWidget {
  const _MoveWindow({Key? key, required this.child}) : super(key: key);

  const _MoveWindow.expand() : child = const SizedBox.expand();

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final needMoveWindow = const [
      TargetPlatform.windows,
      TargetPlatform.macOS,
    ].contains(defaultTargetPlatform);
    if (!needMoveWindow) {
      return child;
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        WindowManager.instance.startDragging();
      },
      onDoubleTap: () async {
        if (await WindowManager.instance.isMaximized()) {
          WindowManager.instance.restore();
        } else {
          WindowManager.instance.maximize();
        }
      },
      child: child,
    );
  }
}

class _CallbackWindowListener extends WindowListener {
  _CallbackWindowListener({
    this.onWindowMinimized,
    this.onWindowMaximized,
    this.onWindowRestored,
    this.onResized,
    this.onMoved,
  });

  final VoidCallback? onWindowMinimized;
  final VoidCallback? onWindowMaximized;
  final VoidCallback? onWindowRestored;
  final VoidCallback? onResized;
  final VoidCallback? onMoved;

  @override
  void onWindowMaximize() {
    onWindowMaximized?.call();
  }

  @override
  void onWindowMinimize() {
    onWindowMinimized?.call();
  }

  @override
  void onWindowRestore() {
    onWindowRestored?.call();
  }

  @override
  void onWindowResize() {
    onResized?.call();
  }

  @override
  void onWindowMove() {
    onMoved?.call();
  }
}
