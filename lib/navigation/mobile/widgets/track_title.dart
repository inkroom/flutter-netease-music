import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/repository.dart';

import '../../../providers/cloud_tracks_provider.dart';
import '../../../providers/player_provider.dart';
import '../../common/playlist/music_list.dart';

class TrackTile extends ConsumerWidget {
  const TrackTile({
    Key? key,
    required this.track,
    required this.index,
  }) : super(key: key);

  final Track track;

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var cloudTracksProviderNotifier = ref.watch(cloudTracksProvider.notifier);

    void addOperator() {
      cloudTracksProviderNotifier.add(track);
    }

    void deleteOperator() {
      cloudTracksProviderNotifier.remove(track);
    }

    void downloadOperator() {
      if (track.type == TrackType.noCopyright) {
        toast(context.strings.trackNoCopyright);
        return;
      } else if (track.type == TrackType.vip) {
        toast(context.strings.trackVIP);
        return;
      }
      toast(context.strings.musicDownloading(track.name));
      cloudTracksProviderNotifier.download(track).then((value) {
        toast(context.strings.musicDownloaded(value.name));

        /// 加入到歌单中
        cloudTracksProviderNotifier.add(track);
      }).catchError((error) {
        toast(context.strings.musicDownloadFail(track.name));
      });
    }

    return InkWell(
      onTap: () {
        if (track.type == TrackType.noCopyright) {
          toast(context.strings.trackNoCopyright);
          return;
        } else if (track.type == TrackType.vip) {
          toast(context.strings.trackVIP);
          return;
        }
        TrackTileContainer.playTrack(context, track);
      },
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            const SizedBox(width: 12),
            SizedBox(
              width: 32,
              child:
                  Center(child: _IndexOrPlayIcon(track: track, index: index)),
            ),
            const SizedBox(width: 8),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (track.type == TrackType.noCopyright)
                        Text(
                          context.strings.tipNoCopyright,
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                              fontSize: 10,
                              color: Colors.white,
                              background: Paint()..color = Colors.red),
                        ),
                      if (track.type == TrackType.vip)
                        Text(
                          context.strings.tipVIP,
                          textAlign: TextAlign.justify,
                          style: context.textTheme.bodyMedium?.copyWith(
                              fontSize: 10,
                              color: Colors.white,
                              background: Paint()..color = Colors.red),
                        ),
                      Text(
                        (track.type != TrackType.free ? ' ' : '') + track.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                            color: track.type == TrackType.noCopyright
                                ? context.theme.disabledColor
                                : null),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.displaySubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text(context.strings.addToMusicList),
                  value: 1,
                ),
                PopupMenuItem(
                  child: Text(context.strings.removeFromMusicList),
                  value: 2,
                ),
                PopupMenuItem(
                  child: Text(context.strings.downloadMusic),
                  value: 3,
                ),
              ],
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 1) {
                  addOperator();
                } else if (value == 2) {
                  deleteOperator();
                } else if (value == 3) {
                  downloadOperator();
                }
                debugPrint('v=$value');
              },
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _IndexOrPlayIcon extends ConsumerWidget {
  const _IndexOrPlayIcon({
    Key? key,
    required this.track,
    required this.index,
  }) : super(key: key);

  final Track track;

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingListId = ref.watch(playingListProvider).id;
    final playingTrack = ref.watch(playingTrackProvider);
    final isCurrent =
        TrackTileContainer.getPlaylistId(context) == playingListId &&
            playingTrack == track;
    final isPlaying = ref.watch(isPlayingProvider);
    if (isCurrent) {
      return isPlaying
          ? const Icon(Icons.volume_up, size: 24)
          : const Icon(Icons.volume_mute, size: 24);
    } else {
      return Text(
        index.toString().padLeft(2, '0'),
        style: context.textTheme.caption!.copyWith(fontSize: 15),
      );
    }
  }
}
