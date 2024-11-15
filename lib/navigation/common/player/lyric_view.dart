import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/providers/lyric_provider.dart';
import 'package:quiet/providers/player_provider.dart';
import 'package:quiet/repository.dart';

import '../progress_track_container.dart';
import 'lyric.dart';

class PlayingLyricView extends ConsumerWidget {
  PlayingLyricView({
    Key? key,
    this.onTap,
    required this.music,
    required this.textStyle,
    this.textAlign = TextAlign.center,
  })  : assert(textStyle.color != null),
        super(key: key);
  final VoidCallback? onTap;

  final Track music;

  final TextAlign textAlign;

  final TextStyle textStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPlaying = ref.watch(playingTrackProvider);

    if (currentPlaying != music) {
      return _LyricViewLoader(music, textAlign, textStyle, onTap);
    }

    return ProgressTrackingContainer(
      builder: (context) => _LyricViewLoader(
        music,
        textAlign,
        textStyle,
        onTap,
      ),
    );
  }
}

class _LyricViewLoader extends ConsumerWidget {
  const _LyricViewLoader(this.music, this.textAlign, this.textStyle, this.onTap,
      {Key? key})
      : super(key: key);

  final Track music;

  final TextAlign textAlign;

  final TextStyle textStyle;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingLyric = ref.watch(lyricProvider(music));
    return playingLyric.when(
      data: (lyric) {
        if (lyric == null || lyric.size <= 0) {
          log('歌词size=${lyric?.size}');
          return InkWell(
            child: Center(
              child: Text(context.strings.noLyric, style: textStyle),
            ),
            onTap: onTap,
          );
        }
        return LayoutBuilder(builder: (context, constraints) {
          return _LyricView(
            lyric: lyric,
            viewportHeight: constraints.maxHeight,
            onTap: onTap,
            textStyle: textStyle,
            textAlign: textAlign,
            track: music,
          );
        });
      },
      error: (error, stack) => InkWell(
        child: Center(
          child: Text(context.formattedError(error), style: textStyle),
        ),
        onTap: onTap,
      ),
      loading: () => Center(
        child: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(color: textStyle.color),
        ),
      ),
    );
  }
}

class _LyricView extends ConsumerWidget {
  const _LyricView({
    Key? key,
    required this.lyric,
    required this.viewportHeight,
    required this.onTap,
    required this.textAlign,
    required this.textStyle,
    required this.track,
  }) : super(key: key);

  final LyricContent lyric;

  final double viewportHeight;

  final VoidCallback? onTap;

  final TextAlign textAlign;

  final TextStyle textStyle;

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = textStyle.color!;
    final normalStyle = textStyle.copyWith(color: color.withOpacity(0.7));

    final currentPlaying = ref.watch(playingTrackProvider);

    final bool playing;
    final Duration? position;

    if (currentPlaying != track) {
      playing = false;
      position = null;
    } else {
      playing = ref.read(playerStateProvider).isPlaying;
      position = ref.read(playerStateProvider.notifier).position;
    }

    return ShaderMask(
      shaderCallback: (rect) {
        // add transparent gradient to lyric top and bottom.
        return ui.Gradient.linear(
          Offset(rect.width / 2, 0),
          Offset(rect.width / 2, viewportHeight),
          [
            color.withOpacity(0),
            color,
            color,
            color.withOpacity(0),
          ],
          const [0.0, 0.15, 0.85, 1],
        );
      },
      child: Lyric(
        lyric: lyric,
        lyricLineStyle: normalStyle,
        highlight: color,
        position: position?.inMilliseconds ?? 0,
        onTap: onTap,
        size: Size(
          viewportHeight,
          viewportHeight == double.infinity ? 0 : viewportHeight,
        ),
        playing: playing,
        textAlign: textAlign,
      ),
    );
  }
}

/// 只有一行的歌词显示器
///
/// 必须使用 [ProgressTrackingContainer] 包裹才生效，原因不明
///
/// 同时用于监听歌词的music也不能通过provider获取，可能是拿到的不是同一个track
///
class SubTitleOrLyric extends ConsumerWidget {
  const SubTitleOrLyric(this.music, {Key? key}) : super(key: key);

  final Track music;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playingLyric = ref.watch(lyricProvider(music));
    final position = ref.read(playerStateProvider.notifier).position;

    return playingLyric.when(
        data: (data) {
          if (data == null) {
            return Text(music.displaySubtitle);
          }
          final line =
              data.getLineByTimeStamp(position?.inMilliseconds ?? 0, 0)?.line;
          if (line == null || line.isEmpty) {
            return Text(
              music.displaySubtitle,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            );
          }
          return Text(
            line,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          );
        },
        // TODO 2022-03-24 歌词获取失败还是会一直刷新 该组件，还是一直走error，
        error: (error, stack) => Text(
              music.displaySubtitle,
              overflow: TextOverflow.ellipsis,
            ),
        loading: () => Center(
              child: SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(
                    color: context.textTheme.bodyMedium?.color),
              ),
            ));
    // if (playingLyric == null) {
    //   return Text(subtitle);
    // }
    // final position = ref
    //     .read(playerStateProvider.notifier)
    //     .position;
    // final line =
    //     playingLyric
    //         .getLineByTimeStamp(position?.inMilliseconds ?? 0, 0)
    //         ?.line;
    // if (line == null || line.isEmpty) {
    //   return Text(subtitle);
    // }
    // return Text(line);
  }
}
