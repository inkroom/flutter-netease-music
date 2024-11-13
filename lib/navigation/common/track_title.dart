import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/common/playlist/music_list.dart';
import 'package:quiet/providers/player_provider.dart';
import 'package:quiet/repository.dart';

/// 歌曲列表的一些通用组件

/// 获取对应的icon
Widget icon(Track track) {
  final MusicApi? api = MusicApiContainer().getApiSync(track.origin);

  return Image(
      width: 18,
      height: 18,
      image: api != null
          ? AssetImage(api.icon, package: api.package)
          : const AssetImage('assets/icons/default_logo.ico'));
}

/// 获取歌曲的一些说明性标签
Widget trackLabel(BuildContext context, String text) {
  return DecoratedBox(
    decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [Colors.red, Colors.orange.shade700]), //背景渐变
        borderRadius: BorderRadius.circular(3.0), //3像素圆角
        boxShadow: const [
          //阴影
          BoxShadow(
              color: Colors.black54, offset: Offset(2.0, 2.0), blurRadius: 4.0)
        ]),
    child: Padding(
        padding: const EdgeInsets.fromLTRB(3, 1, 3, 1),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            fontSize: 10,
            color: Colors.white,
          ),
        )),
  );
}

/// 数字或者播放标志
class IndexOrPlayIcon extends ConsumerWidget {
  const IndexOrPlayIcon({
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
          size: 20,
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

/// 歌曲标记复选框
class TrackFlagCheckbox extends StatefulWidget {
  const TrackFlagCheckbox(this.operator, this.bit, this.track, this.color);

  final TrackOperator operator;
  final int bit;
  final Track track;
  final Color color;

  @override
  State<StatefulWidget> createState() => _FlagCheckboxState();
}

class _FlagCheckboxState extends State<TrackFlagCheckbox> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    _value = widget.track.flag & widget.bit == widget.bit;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
        value: _value,
        activeColor: widget.color,
        side: BorderSide(color: widget.color),
        onChanged: (bool? value) {
          debugPrint("之前的flag=${widget.track.flag}");
          if (value == true) {
            widget.track.flag = widget.track.flag | widget.bit;
          } else if (value == false) {
            widget.track.flag = (widget.track.flag | widget.bit) ^ widget.bit;
          }
          _value = widget.track.flag & widget.bit == widget.bit;
          debugPrint("之后的flag=${widget.track.flag}");
          widget.operator.flag(widget.track);
          setState(() {
            _value = widget.track.flag & widget.bit == widget.bit;
          });
        });
  }
}
