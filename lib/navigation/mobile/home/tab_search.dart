import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/common/playlist/music_list.dart';
import 'package:quiet/navigation/mobile/widgets/track_title.dart';

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
          child: Text(context.formattedError(error)),
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
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CupertinoSearchTextField(
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
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
