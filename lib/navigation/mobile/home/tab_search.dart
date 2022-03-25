import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/common/playlist/music_list.dart';
import 'package:quiet/navigation/mobile/widgets/track_title.dart';
import 'package:quiet/repository.dart';
import 'package:list_tile_more_customizable/list_tile_more_customizable.dart';
import '../../../providers/player_provider.dart';
import '../../../providers/search_provider.dart';

class HomeTabSearch extends ConsumerWidget {
  const HomeTabSearch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchResult = ref.watch(mobileSearchMusicProvider(''));
    log('查询数据了');

    return Scaffold(
      appBar: _SearchTextField(),
      body: searchResult.value.when(
        data: (data) => TrackTileContainer.cloudTracks(
            tracks: data,
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) => TrackTile(
                track: data[index],
                index: index + 1,
              ),
              itemCount: data.length,
            ),
            player: ref.read(playerProvider)),
        error: (error, stacktrace) => Center(
          child: Text(context.formattedError(error, stacktrace: stacktrace)),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _SearchTextField extends ConsumerWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MusicApiContainer.instance.list.map((e) =>
    //     RadioListTile(title: Text(e.name),
    //         value: e.origin,
    //         groupValue: 1,
    //         onChanged: (value) => {})).toList();

    // return Column(
    //   children: [
    //     Row(
    //       children: [
    //         RadioListTile<int>(
    //             title: Text('e.name'),
    //             value: 1,
    //             groupValue: 1,
    //             onChanged: (value) => {})
    //       ],
    //     ),
    //   ],
    // );

    final origin = ref.watch(mobileSearchMusicProvider('')).origin;

    log('来源origin = $origin');

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
              child: Row(
            children: MusicApiContainer.instance.list
                .map((e) => Expanded(
                    flex: 1,
                    child: _RadioListTile<int>(
                        title: e.name,
                        value: e.origin,
                        groupValue: origin,
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(mobileSearchMusicProvider('').notifier)
                                .origin = value;
                          }
                        })))
                .toList(),
          )),
          CupertinoSearchTextField(
            style: context.textTheme.bodyMedium,
            placeholder: context.strings.search,
            enabled: true,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: CupertinoColors.inactiveGray,
              ),
            ),
            onChanged: (value) {
              log('查询的value=$value');
              if (value.trim().isNotEmpty) {
                ref
                    .read(mobileSearchMusicProvider('').notifier)
                    .search(value.trim());
              }
            },
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
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
