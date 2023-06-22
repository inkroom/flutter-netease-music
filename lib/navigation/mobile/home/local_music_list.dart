import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/component.dart';
import 'package:quiet/navigation/common/playlist/music_list.dart';
import 'package:quiet/navigation/mobile/widgets/track_title.dart';
import 'package:quiet/providers/cloud_tracks_provider.dart';
import 'package:quiet/providers/player_provider.dart';

/// 本地音乐歌单
class LocalMusicList extends ConsumerWidget {
  const LocalMusicList({Key? key}) : super(key: key);

  /// 实现有点简单粗暴
  static ScrollPosition? _position;

  final double _itemHeight = 60;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 显示的时候倒序，存储依然正序
    final filterFlag =
        ref.watch(cloudTracksProvider.select((value) => value.filterFlag));
    final intersection = ref.watch(cloudTracksProvider
        .select((value) => value.intersection)); //true 则是取交集，否则取并集
    final list = ref.watch(cloudTracksProvider).tracks;
    final r = list.reversed.where((element) {
      if (filterFlag == 0) return true;
      if (intersection == true) return element.flag & filterFlag == filterFlag;
      return element.flag & filterFlag > 0;
    }).toList();
    if (r.isEmpty) {
      return Center(
        child: Text(context.strings.emptyList),
      );
    }

    ScrollController _controller;
    if (_position != null) {
      _controller = ScrollController(initialScrollOffset: _position!.pixels);
    } else {
      _controller = ScrollController();
    }

    _controller.addListener(() {
      _position = _controller.position;
    });

    return Stack(
      children: [
        TrackTileContainer.cloudTracks(
            tracks: list,
            child: ListView.builder(
              controller: _controller,
              shrinkWrap: true,
              itemExtent: _itemHeight,
              itemBuilder: (context, index) => TrackTile(
                track: r[index],
                index: index + 1,
              ),
              itemCount: r.length,
            ),
            player: ref.read(playerProvider)),
        Positioned(
            bottom: 30,
            right: 35,
            child: IconButton(
              icon: const Icon(Icons.all_out),
              onPressed: () {
                final track = ref.read(playerProvider).current;
                if (track != null) {
                  final index = r.indexWhere((element) =>
                      track.id == element.id && track.extra == element.extra);
                  _controller.animateTo(index * _itemHeight,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn);
                }
              },
            ))
      ],
    );
  }
}
