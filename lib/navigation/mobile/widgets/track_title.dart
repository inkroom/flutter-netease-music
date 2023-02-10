import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/repository.dart';

import '../../common/playlist/music_list.dart';
import '../../common/track_title.dart';

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
                        trackLabel(
                          context,
                          context.strings.tipNoCopyright,
                        ),
                      if (track.type == TrackType.vip)
                        trackLabel(
                          context,
                          context.strings.tipVIP,
                        ),
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
                PopupMenuItem(
                  child: Text(context.strings.trackFlagSetting),
                  value: 4,
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
                } else if (value == 4) {
                  //标记歌曲

                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            content: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: TrackFlag.values
                                    .map((e) => TrackFlagCheckbox(
                                        operator, e.bit, track, e.color))
                                    .toList(growable: false)),
                          ));

                  // showDialog(
                  //     barrierDismissible: false,
                  //     context: context,
                  //     builder: (BuildContext context) => SizedBox(
                  //           height: 200,
                  //           width: 400,
                  //           // constraints:const BoxConstraints(maxHeight: 200,maxWidth: 400),
                  //           child: Container(
                  //             alignment: Alignment.center,
                  //             child: Row(
                  //               mainAxisSize: MainAxisSize.min,
                  //               children: [
                  //
                  //                 // Checkbox(
                  //                 //     value: track.flag & 1 == 1,
                  //                 //     side: const BorderSide(color: Colors.red),
                  //                 //     onChanged: (bool? value) {}),
                  //                 // Checkbox(
                  //                 //     value: track.flag & 2 == 2,
                  //                 //     side:
                  //                 //         const BorderSide(color: Colors.blue),
                  //                 //     onChanged: (bool? value) {}),
                  //               ],
                  //             ),
                  //           ),
                  //         ));
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
