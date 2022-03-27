import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/material.dart';
import 'package:quiet/navigation/common/navigation_target.dart';
import 'package:quiet/navigation/common/player/lyric_view.dart';
import 'package:quiet/navigation/common/player_progress.dart';
import 'package:quiet/providers/navigator_provider.dart';

import '../../../pages/page_playing_list.dart';
import '../../../providers/lyric_provider.dart';
import '../../../providers/player_provider.dart';
import '../../common/like_button.dart';
import '../../common/progress_track_container.dart';

const kBottomPlayerBarHeight = 56.0;

class AnimatedAppBottomBar extends HookConsumerWidget {
  const AnimatedAppBottomBar({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute =
        ref.watch(navigatorProvider.select((value) => value.current));
    final lastHomeTarget = useRef<NavigationTarget?>(null);

    final NavigationTarget currentTab;

    final bool hideNavigationBar;
    if (!kMobileHomeTabs.contains(currentRoute.runtimeType)) {
      currentTab = lastHomeTarget.value ?? NavigationTargetMy();
      hideNavigationBar = true;
    } else {
      currentTab = currentRoute;
      hideNavigationBar = false;
    }
    lastHomeTarget.value = currentTab;

    assert(kMobileHomeTabs.contains(currentTab.runtimeType));

    const navigationBarHeight = kBottomNavigationBarHeight + 2;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final music = ref.watch(playingTrackProvider);

    const kNoPlayerBarPages = {
      NavigationTargetPlaying,
      NavigationTargetFmPlaying,
      NavigationTargetSettings,
      NavigationTargetLogin,
    };
    const playerBarHeight = kBottomPlayerBarHeight;
    final hidePlayerBar =
        music == null || kNoPlayerBarPages.contains(currentRoute.runtimeType);

    final double height;
    final double navigationBarBottom;
    final double playerBarBottom;
    final double processBarHeight = 10;
    if (hidePlayerBar && hideNavigationBar) {
      height = 0;
      navigationBarBottom = -playerBarHeight - navigationBarHeight;
      playerBarBottom = -playerBarHeight;
    } else if (hidePlayerBar) {
      height = navigationBarHeight + bottomPadding;
      navigationBarBottom = bottomPadding;
      playerBarBottom = -playerBarHeight;
    } else if (hideNavigationBar) {
      height = playerBarHeight + bottomPadding;
      navigationBarBottom = -navigationBarHeight;
      playerBarBottom = bottomPadding;
    } else {
      navigationBarBottom = bottomPadding;
      playerBarBottom = navigationBarHeight + bottomPadding;
      height = playerBarHeight + navigationBarHeight + bottomPadding;
    }

    return Stack(
      children: [
        /// 主体部分
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          top: 0,
          left: 0,
          right: 0,
          bottom: height,
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: !hidePlayerBar || !hideNavigationBar,
            child: child,
          ),
          curve: Curves.easeInOut,
        ),

        /// 底部播放栏部分
        AnimatedPositioned(
          height: playerBarHeight,
          left: 0,
          right: 0,
          duration: const Duration(milliseconds: 300),
          bottom: playerBarBottom,
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: hidePlayerBar ? 0 : 1,
            curve: Curves.easeIn,
            child: const BottomPlayerBar(),
          ),
        ),

        /// 进度条
        AnimatedPositioned(
          height: processBarHeight,
          left: 0,
          right: 0,
          duration: const Duration(milliseconds: 300),

          /// bottom是调整过的，保证在bottom边缘上
          bottom: navigationBarHeight +
              kBottomPlayerBarHeight -
              processBarHeight / 2,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: hidePlayerBar ? 0 : 1,
            curve: Curves.easeIn,
            child: SliderTheme(
              data: const SliderThemeData(
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                showValueIndicator: ShowValueIndicator.always,
              ),
              child: PlayerProgressSlider(builder: (context, widget) => widget),
            ),
          ),
        ),

        /// 底部导航栏部分
        AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          bottom: navigationBarBottom,
          left: 0,
          right: 0,
          height: navigationBarHeight,
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: hideNavigationBar ? 0 : 1,
            curve: Curves.easeIn,
            child: ClipRect(
              child: MediaQuery.removePadding(
                removeBottom: true,
                context: context,
                child: HomeBottomNavigationBar(currentTab: currentTab),
              ),
            ),
          ),
        ),
        AnimatedPositioned(
          child: const Material(elevation: 8),
          duration: const Duration(milliseconds: 300),
          bottom: 0,
          left: 0,
          right: 0,
          curve: Curves.easeInOut,
          height: hidePlayerBar && hideNavigationBar ? 0 : bottomPadding,
        ),
      ],
    );
  }
}

class BottomPlayerBar extends ConsumerWidget {
  const BottomPlayerBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final music = ref.watch(playingTrackProvider);
    final queue = ref.watch(playingListProvider);
    if (music == null) {
      return const SizedBox(height: kBottomPlayerBarHeight);
    }

    return Material(
      elevation: 8,
      child: InkWell(
          onTap: () => ref.read(navigatorProvider.notifier).navigate(queue.isFM
              ? NavigationTargetFmPlaying()
              : NavigationTargetPlaying()),
          child: SizedBox(
            height: kBottomPlayerBarHeight,
            child: Row(
              children: [
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  child: QuietImage(
                    fit: BoxFit.cover,
                    url: music.imageUrl?.toString(),
                    assets: "assets/playing_page_disc.png",
                    width: 48,
                    height: 48,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DefaultTextStyle(
                    style: const TextStyle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          music.name,
                          style: context.textTheme.bodyText2,
                        ),
                        const SizedBox(height: 2),
                        DefaultTextStyle(
                          maxLines: 1,
                          style: context.textTheme.caption!,
                          child: ProgressTrackingContainer(
                            builder: (context) => SubTitleOrLyric(music),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _PauseButton(),
                if (queue.isFM)
                  LikeButton(music: music)
                else
                  IconButton(
                    tooltip: context.strings.playingList,
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      PlayingListDialog.show(context);
                    },
                  ),
              ],
            ),
          )),
    );
  }
}

class _PauseButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PlayingIndicator(
      playing: IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () {
            ref.read(playerStateProvider.notifier).pause();
          }),
      pausing: IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () {
            ref.read(playerStateProvider.notifier).play();
          }),
      buffering: Container(
        height: 24,
        width: 24,
        //to fit  IconButton min width 48
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(4),
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

class HomeBottomNavigationBar extends ConsumerWidget {
  const HomeBottomNavigationBar({
    Key? key,
    required this.currentTab,
  }) : super(key: key);

  final NavigationTarget currentTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      currentIndex: kMobileHomeTabs.indexWhere(
        (element) => element == currentTab.runtimeType,
      ),
      selectedItemColor: context.colorScheme.primary,
      unselectedItemColor: context.colorScheme.onBackground,
      onTap: (index) {
        final NavigationTarget target;
        switch (index) {
          case 0:
            target = NavigationTargetDiscover();
            break;
          case 1:
            target = NavigationTargetLibrary();
            break;
          case 2:
            target = NavigationTargetMy();
            break;
          case 3:
            target = NavigationTargetLocal();
            break;
          case 4:
            target = NavigationTargetSearch();
            break;
          default:
            assert(false, 'unknown index: $index');
            target = NavigationTargetDiscover();
        }
        ref.read(navigatorProvider.notifier).navigate(target);
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.compass_calibration_rounded),
          label: context.strings.discover,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.my_library_music),
          label: context.strings.library,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: context.strings.my,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.file_copy),
          label: context.strings.localMusic,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search),
          label: context.strings.search,
        ),
      ],
    );
  }
}
