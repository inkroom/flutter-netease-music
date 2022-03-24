import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/navigation/common/playlist/music_list.dart';
import 'package:quiet/navigation/mobile/widgets/track_title.dart';
import 'package:quiet/providers/cloud_tracks_provider.dart';
import 'package:quiet/providers/player_provider.dart';
import 'package:quiet/component.dart';
import 'package:quiet/repository.dart';

/// 本地音乐歌单
class LocalMusicList extends ConsumerWidget {
  const LocalMusicList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 显示的时候倒序，存储依然正序
    final r = ref.watch(cloudTracksProvider).tracks.reversed.toList();
    if (r.isEmpty) {
      return Center(
        child: Text(context.strings.emptyList),
      );
    }
    return TrackTileContainer.cloudTracks(
        tracks: r,
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) => TrackTile(
            track: r[index],
            index: index + 1,
          ),
          itemCount: r.length,
        ),
        player: ref.read(playerProvider));
  }
}
