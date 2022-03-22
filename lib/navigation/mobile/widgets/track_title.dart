import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/repository.dart';

import '../../../providers/player_provider.dart';
import '../../common/track_title.dart';
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
    final operator = TrackOperator(context: context, ref: ref);

    return InkWell(
      onTap: () => operator.playTrack(context, track),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: icon(track),
            ),
            SizedBox(
              width: 32,
              child: IndexOrPlayIcon(track: track, index: index),
              // Center(child: _IndexOrPlayIcon(track: track, index: index)),
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
                      trackLabel(Text(
                        context.strings.tipNoCopyright,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      )),
                      if (track.type == TrackType.vip)
                        trackLabel(Text(
                          context.strings.tipVIP,
                          textAlign: TextAlign.justify,
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        )),
                      Expanded(
                          child: Text(
                        (track.type != TrackType.free ? ' ' : '') + track.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                            color: track.type == TrackType.noCopyright
                                ? context.theme.disabledColor
                                : null),
                      )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (track.file != null)
                        const Icon(
                          Icons.download_done_outlined,
                          size: 16,
                        ),
                      Expanded(
                          child: Text(
                        track.displaySubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.caption,
                      ))
                    ],
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
                  operator.addOperator(track);
                } else if (value == 2) {
                  operator.deleteOperator(track);
                } else if (value == 3) {
                  operator.downloadOperator(track);
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
