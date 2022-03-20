import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/navigation/common/playlist/music_list.dart';
import 'package:quiet/navigation/mobile/widgets/track_title.dart';
import 'package:quiet/providers/cloud_tracks_provider.dart';
import 'package:quiet/providers/player_provider.dart';

/// 本地音乐名单
class LocalMusicList extends ConsumerWidget {
  const LocalMusicList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(cloudTracksProvider);

    return TrackTileContainer.cloudTracks(
        tracks: r.tracks,
        child: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) => TrackTile(
            track: r.tracks[index],
            index: index + 1,
          ),
          itemCount: r.tracks.length,
        ),
        player: ref.read(playerProvider));
  }
}
