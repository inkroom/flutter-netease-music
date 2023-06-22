import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/navigation/common/settings.dart';
import 'package:quiet/navigation/mobile/home/local_music_list.dart';
import 'package:quiet/navigation/mobile/home/main_page_discover.dart';
import 'package:quiet/navigation/mobile/home/main_page_my.dart';
import 'package:quiet/navigation/mobile/home/tab_search.dart';
import 'package:quiet/providers/cloud_tracks_provider.dart';
import 'package:quiet/repository.dart';

import '../../../providers/navigator_provider.dart';
import '../../common/navigation_target.dart';
import 'tab_discover.dart';

class PageHome extends StatelessWidget {
  PageHome({Key? key, required this.selectedTab})
      : assert(selectedTab.isMobileHomeTab()),
        super(key: key);

  final NavigationTarget selectedTab;

  @override
  Widget build(BuildContext context) {
    final Widget body;
    log('当前跳转=${selectedTab.runtimeType}');
    switch (selectedTab.runtimeType) {
      case NavigationTargetDiscover:
        body = const HomeTabDiscover();
        break;
      case NavigationTargetMy:
        body = MainPageMy();
        break;
      case NavigationTargetLibrary:
        body = MainPageDiscover();
        break;
      case NavigationTargetSearch:
        body = const HomeTabSearch();
        break;
      case NavigationTargetLocal:
        body = const LocalMusicList();
        break;
      default:
        assert(false, 'unsupported tab: $selectedTab');
        body = MainPageMy();
        break;
    }
    return Scaffold(appBar: const _AppBar(), body: body);
  }
}

class _AppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _AppBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = <Widget>[];
    w.addAll(TrackFlag.values
        .map((e) => Checkbox(
            value: ref.watch(cloudTracksProvider
                        .select((value) => value.filterFlag)) &
                    e.bit ==
                e.bit,
            activeColor: e.color,
            side: BorderSide(color: e.color),
            onChanged: (bool? value) {
              if (value == true) {
                ref
                    .read(cloudTracksProvider.notifier)
                    .filter(ref.read(cloudTracksProvider).filterFlag | e.bit);
              } else {
                ref.read(cloudTracksProvider.notifier).filter(
                    (ref.read(cloudTracksProvider).filterFlag | e.bit) ^ e.bit);
              }
            }))
        .toList());

    w.add(Switch(
        value: ref
            .watch(cloudTracksProvider.select((value) => value.intersection)),
        onChanged: (bool? value) {
          ref.read(cloudTracksProvider.notifier).filter(
              ref.read(cloudTracksProvider).filterFlag,
              intersection: value);
        }));

    return AppBar(
      title: Row(
        children: w,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () => ref
              .read(navigatorProvider.notifier)
              .navigate(NavigationTargetSettings()),
          icon: const Icon(Icons.settings),
          splashRadius: 24,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
