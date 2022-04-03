import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/material.dart';
import 'package:quiet/component.dart';
import 'package:quiet/media/tracks/tracks_player.dart';
import 'package:quiet/navigation/common/buttons.dart';
import 'package:quiet/providers/player_provider.dart';

import '../like_button.dart';

class PlayingOperationBar extends ConsumerWidget {
  const PlayingOperationBar({
    Key? key,
    this.iconColor,
  }) : super(key: key);

  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconColor = this.iconColor ?? context.theme.primaryIconTheme.color;
    final music = ref.watch(playingTrackProvider)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        LikeButton(music: music, color: iconColor),
        IconButton(
          icon: Icon(Icons.comment, color: iconColor),
          onPressed: () => toast(context.strings.todo),
        ),
        IconButton(
          icon: Icon(Icons.share, color: iconColor),
          onPressed: () => toast(context.strings.todo),
        ),
      ],
    );
  }
}
/// 播放模式控制器
class RepeatModeControl extends ConsumerWidget {
  const RepeatModeControl({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(playerStateProvider).mode;
    final m = ref.read(playerProvider);
    IconData i = Icons.autorenew;
    if (mode == RepeatMode.random) {
      i = Icons.shuffle;
    } else if (mode == RepeatMode.next) {
      i = Icons.next_plan;
    } else if (mode == RepeatMode.one) {
      i = Icons.repeat_one;
    } else if (mode == RepeatMode.none) {
      i = Icons.close_outlined;
    }
    return AppIconButton(
      icon: i,
      size: 24,
      onPressed: () {
        if (mode == RepeatMode.random) {
          m.repeatMode = RepeatMode.next;
          toast(context.strings.repeatModeNext);
        } else if (mode == RepeatMode.next) {
          m.repeatMode = RepeatMode.one;
          toast(context.strings.repeatModeOne);
        } else if (mode == RepeatMode.one) {
          m.repeatMode = RepeatMode.none;
          toast(context.strings.repeatModeNone);
        } else if (mode == RepeatMode.none) {
          m.repeatMode = RepeatMode.random;
          toast(context.strings.repeatModeRandom);
        }
      },
    );
  }
}