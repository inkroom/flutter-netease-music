import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:list_tile_more_customizable/list_tile_more_customizable.dart';
import 'package:quiet/component.dart';
import 'package:quiet/providers/search_provider.dart';
import 'package:quiet/repository.dart';

/// 搜索来源选择框
class SearchOrigin extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final origin = ref.watch(searchMusicProvider('')).origin;
    return Row(
      children: MusicApiContainer.instance.list
          .map((e) => Expanded(
              flex: 1,
              child: _RadioListTile<int>(
                  title: e.name,
                  value: e.origin,
                  groupValue: origin,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(searchMusicProvider('').notifier).origin = value;
                    }
                  })))
          .toList(),
    );
  }
}

class _RadioListTile<T> extends StatelessWidget {
  const _RadioListTile(
      {Key? key,
      required this.title,
      required this.groupValue,
      required this.value,
      required this.onChanged});

  final String title;
  final T? groupValue;
  final T value;
  final ValueChanged<T?>? onChanged;

  bool get checked => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final Widget control = Radio<T>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    return MergeSemantics(
      child: ListTileTheme.merge(
        selectedColor: Theme.of(context).toggleableActiveColor,
        child: ListTileMoreCustomizable(
          contentPadding: EdgeInsets.zero,
          // leading: control,
          title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            control,
            Text(
              title,
              overflow: TextOverflow.clip,
              style: context.textTheme.bodySmall,
            ),
          ]),
          minLeadingWidth: 0,
          horizontalTitleGap: 0.0,
          enabled: onChanged != null,
          onTap: (details) {
            if (onChanged != null) {
              if (checked) {
                onChanged!(null);
                return;
              }
              if (!checked) {
                onChanged!(value);
              }
            }
          },
        ),
      ),
    );
  }
}
