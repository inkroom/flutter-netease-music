import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quiet/component/utils/utils.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/media/tracks/tracks_player.dart';
import 'package:quiet/navigation/common/progress_track_container.dart';
import 'package:quiet/providers/player_provider.dart';

/// A seek bar for current position.
class DurationProgressBar extends ConsumerWidget {
  const DurationProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliderTheme(
      data: const SliderThemeData(
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
        showValueIndicator: ShowValueIndicator.always,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: PlayerProgressSlider(builder: (context, widget) {
          return Row(
            children: <Widget>[
              const Padding(padding: EdgeInsets.only(left: 4)),
              Expanded(
                child: widget,
              ),
              const Padding(padding: EdgeInsets.only(left: 4)),
            ],
          );
        }),
      ),
    );
  }
}

class PlayerProgressSlider extends HookConsumerWidget {
  const PlayerProgressSlider({
    Key? key,
    this.builder,
  }) : super(key: key);

  final Widget Function(BuildContext context, Widget slider)? builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTrackingValue = useState<double?>(null);
    final player = ref.read(playerProvider);

    return ProgressTrackingContainer(
      builder: (context) {
        final snapshot = _PlayerProgressSliderSnapshot(
          player: player,
          userTrackingValue: userTrackingValue,
        );
        return builder == null ? snapshot : builder!(context, snapshot);
      },
    );
  }
}

class _PlayerProgressSliderSnapshot extends StatelessWidget {
  const _PlayerProgressSliderSnapshot({
    Key? key,
    required this.player,
    required this.userTrackingValue,
  }) : super(key: key);

  final TracksPlayer player;

  final ValueNotifier<double?> userTrackingValue;

  @override
  Widget build(BuildContext context) {
    final position = player.position?.inMilliseconds.toDouble() ?? 0.0;
    final duration = player.duration?.inMilliseconds.toDouble() ?? 0.0;
    final positionText = player.position?.timeStamp;
    final durationText = player.duration?.timeStamp;
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Text(
            positionText ?? '00:00',
            style: context.textTheme.bodyMedium,
          ),
        ),
        Expanded(
            child: Slider(
          max: duration,
          value: (userTrackingValue.value ?? position).clamp(
            0.0,
            duration,
          ),
          onChangeStart: (value) => userTrackingValue.value = value,
          onChanged: (value) => userTrackingValue.value = value,
          semanticFormatterCallback: (value) => getTimeStamp(value.round()),
          onChangeEnd: (value) {
            userTrackingValue.value = null;
            player
              ..seekTo(Duration(milliseconds: value.round()))
              ..play();
          },
        )),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Text(durationText ?? '00:00',
              style: context.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
