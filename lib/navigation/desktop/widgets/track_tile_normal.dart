import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/material.dart';
import 'package:quiet/navigation/common/like_button.dart';
import 'package:quiet/navigation/common/playlist/music_list.dart';
import 'package:quiet/providers/navigator_provider.dart';
import 'package:quiet/providers/player_provider.dart';
import 'package:quiet/repository.dart';

import '../../common/navigation_target.dart';
import '../../common/track_title.dart';
import 'highlight_clickable_text.dart';

class TrackTableContainer extends StatelessWidget {
  const TrackTableContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => _TrackTableContainer(
        width: constraints.maxWidth - 110,
        child: child,
      ),
    );
  }
}

class _TrackTableContainer extends StatefulWidget {
  const _TrackTableContainer({
    Key? key,
    required this.child,
    required this.width,
  }) : super(key: key);

  final Widget child;

  final double width;

  @override
  State<_TrackTableContainer> createState() => _TrackTableContainerState();

  static _TrackTableContainerState of(BuildContext context) {
    final state = context.findAncestorStateOfType<_TrackTableContainerState>();
    assert(state != null, '_TrackTableContainerState not found');
    return state!;
  }
}

class _TrackTableContainerState extends State<_TrackTableContainer> {
  final int indexFlex = 9;
  final int likeFlex = 4;
  final int nameFlex = 30;
  final int artistFlex = 18;
  final int albumFlex = 20;
  final int durationFlex = 6;
  final int operatorFlex = 16;

  @override
  Widget build(BuildContext context) {
    return _TrackTableConfiguration(
      indexFlex: indexFlex,
      likeFlex: likeFlex,
      nameFlex: nameFlex,
      artistFlex: artistFlex,
      albumFlex: albumFlex,
      durationFlex: durationFlex,
      operatorFlex: operatorFlex,
      child: widget.child,
    );
  }
}

class _TrackTableConfiguration extends InheritedWidget {
  const _TrackTableConfiguration({
    Key? key,
    required Widget child,
    required this.indexFlex,
    required this.likeFlex,
    required this.nameFlex,
    required this.artistFlex,
    required this.albumFlex,
    required this.durationFlex,
    required this.operatorFlex,
  }) : super(key: key, child: child);

  final int indexFlex;
  final int likeFlex;
  final int nameFlex;
  final int artistFlex;
  final int albumFlex;
  final int durationFlex;
  final int operatorFlex;

  static _TrackTableConfiguration of(BuildContext context) {
    final _TrackTableConfiguration? result =
        context.dependOnInheritedWidgetOfExactType<_TrackTableConfiguration>();
    assert(result != null, 'No _TrackTableConfiguration found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(_TrackTableConfiguration old) {
    return false;
  }
}

class TrackTableHeader extends StatelessWidget implements PreferredSizeWidget {
  const TrackTableHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: context.textTheme.caption!,
      child: SizedBox.fromSize(
        size: preferredSize,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(
              flex: _TrackTableConfiguration.of(context).indexFlex +
                  _TrackTableConfiguration.of(context).likeFlex +
                  3,
            ),
            Expanded(
              child: Text(context.strings.musicName),
              flex: _TrackTableConfiguration.of(context).nameFlex,
            ),

            /// 歌手
            Expanded(
              child: Text(context.strings.artists),
              flex: _TrackTableConfiguration.of(context).artistFlex - 1,
            ),

            /// 专辑
            Expanded(
              child: Text(context.strings.album),
              flex: _TrackTableConfiguration.of(context).albumFlex,
            ),

            /// 时长
            Expanded(
              child: Text(context.strings.duration),
              flex: _TrackTableConfiguration.of(context).durationFlex,
            ),
            const SizedBox(width: 20),
            Spacer(
              flex: _TrackTableConfiguration.of(context).operatorFlex,
            ),
          ],
        ),
      ),
    );
  }

  // @override
  Size get preferredSize => const Size.fromHeight(40);
}

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
    final configuration = _TrackTableConfiguration.of(context);

    final operator = TrackOperator(context: context, ref: ref);
    return SizedBox(
        height: 36,
        child: Material(
          color: index.isEven
              ? context.colorScheme.background
              : context.colorScheme.primary.withOpacity(0.04),
          child: InkWell(
            onTap: () => operator.playTrack(context, track),
            child: DefaultTextStyle(
              style: const TextStyle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: configuration.indexFlex,
                      child: Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Row(
                          children: [
                            Padding(
                              child: icon(track),
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            ),
                            IndexOrPlayIcon(index: index, track: track)
                          ],
                        ),
                      )),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LikeButton(
                      music: track,
                      iconSize: 16,
                      padding: const EdgeInsets.all(2),
                      likedColor: context.colorScheme.primary,
                      color: context.textTheme.caption?.color,
                    ),
                    flex: configuration.likeFlex,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: configuration.nameFlex,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
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
                              (track.type != TrackType.free ? ' ' : '') +
                                  track.name,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                color: track.type == TrackType.noCopyright
                                    ? context.theme.disabledColor
                                    : null,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: configuration.artistFlex,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: MouseHighlightText(
                        style: context.textTheme.caption,
                        highlightStyle: context.textTheme.caption!.copyWith(
                          color: context.textTheme.bodyMedium!.color,
                        ),
                        children: track.artists
                            .map((artist) => MouseHighlightSpan.highlight(
                                  text: artist.name,
                                  onTap: () {
                                    if (track.origin != 1) {
                                      toast(context.strings.unsupportedOrigin);
                                      return;
                                    }
                                    if (artist.id == 0) {
                                      return;
                                    }
                                    ref
                                        .read(navigatorProvider.notifier)
                                        .navigate(NavigationTargetArtistDetail(
                                            artist.id));
                                  },
                                ))
                            .separated(MouseHighlightSpan.normal(text: '/'))
                            .toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: configuration.albumFlex,
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: HighlightClickableText(
                        text: track.album?.name ?? '',
                        onTap: () {
                          if (track.origin == 1) {
                            final albumId = track.album?.id;
                            if (albumId == null) {
                              return;
                            }
                            ref
                                .read(navigatorProvider.notifier)
                                .navigate(NavigationTargetAlbumDetail(albumId));
                          } else {
                            toast(context.strings.unsupportedOrigin);
                          }
                        },
                        style: context.textTheme.caption,
                        highlightStyle: context.textTheme.caption?.copyWith(
                          color: context.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: configuration.durationFlex,
                      child: Text(
                        track.duration.timeStamp,
                        style: context.textTheme.caption,
                      )),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: configuration.operatorFlex,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => operator.downloadOperator(track),
                          child: Icon(track.file != null
                              ? Icons.download_done_outlined
                              : Icons.download_outlined),
                        ),
                        InkWell(
                          onTap: () => operator.addOperator(track),
                          child: const Icon(Icons.add_outlined),
                        ),
                        InkWell(
                          onTap: () => operator.deleteOperator(track),
                          child: const Icon(Icons.delete_outline),
                        ),
                        InkWell(
                          onTap: () => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    content: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: TrackFlag.values
                                            .map((e) => TrackFlagCheckbox(
                                                operator,
                                                e.bit,
                                                track,
                                                e.color))
                                            .toList(growable: false)),
                                  )),
                          child: const Icon(Icons.flag),
                        ),

                        // AppIconButton(
                        //     padding: EdgeInsets.zero,
                        //     onPressed: () => operator.downloadOperator(track),
                        //     icon: track.file != null
                        //         ? Icons.download_done_outlined
                        //         : Icons.download_outlined),
                        // AppIconButton(
                        //     padding: EdgeInsets.zero,
                        //     onPressed: () => operator.addOperator(track),
                        //     icon: Icons.add_outlined),
                        // AppIconButton(
                        //     padding: EdgeInsets.zero,
                        //     onPressed: () => operator.deleteOperator(track),
                        //     icon: Icons.delete_outline),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ));
  }
}

class _IndexOrPlayIcon extends ConsumerWidget {
  const _IndexOrPlayIcon({
    Key? key,
    required this.index,
    required this.track,
  }) : super(key: key);

  final int index;
  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingListId = ref.watch(playingListProvider).id;
    final playingTrack = ref.watch(playingTrackProvider);
    final isCurrent =
        TrackTileContainer.getPlaylistId(context) == playingListId &&
            playingTrack == track;
    final isPlaying = ref.watch(isPlayingProvider);
    if (isCurrent) {
      return IconTheme(
        data: IconThemeData(
          color: context.colorScheme.primary,
          size: 16,
        ),
        child: isPlaying
            ? const Icon(Icons.volume_up)
            : const Icon(Icons.volume_mute),
      );
    } else {
      return Text(
        index.toString().padLeft(2, '0'),
        style: context.textTheme.caption,
      );
    }
  }
}
