import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quiet/component/utils/scroll_controller.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/common/playlist/music_list.dart';
import 'package:quiet/navigation/desktop/widgets/track_tile_normal.dart';
import 'package:quiet/repository.dart';

import '../../../providers/player_provider.dart';
import '../../../providers/search_provider.dart';
import 'page_search.dart';

class PageMusicSearchResult extends ConsumerWidget {
  const PageMusicSearchResult(
      {Key? key, required this.query, required this.origin})
      : super(key: key);

  final String query;
  final int origin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log("得到的 query = $query");
    final searchResult =
        ref.watch(searchMusicProvider(query + origin.toString()));
    return searchResult.value.when(
      data: (data) => SearchResultScaffold(
        query: query,
        queryResultDescription: context.strings.searchMusicResultCount(
            searchResult.totalItemCount,
            MusicApiContainer.instance.getApiSync(origin)?.name ?? "未知"),
        body: data.isEmpty
            ? Center(
                child: Text(context.strings.noMusic),
              )
            : _TrackList(tracks: data),
      ),
      error: (error, stacktrace) => SearchResultScaffold(
        query: query,
        queryResultDescription: '',
        body: Center(
          child: Text(context.formattedError(error, stacktrace: stacktrace)),
        ),
      ),
      loading: () => SearchResultScaffold(
        query: query,
        queryResultDescription: '',
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _TrackList extends HookConsumerWidget {
  const _TrackList({
    Key? key,
    required this.tracks,
  }) : super(key: key);
  final List<Track> tracks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAppScrollController();
    return TrackTileContainer.simpleList(
      tracks: tracks,
      player: ref.read(playerProvider),
      child: TrackTableContainer(
        child: Column(
          children: [
            const TrackTableHeader(),
            Expanded(
              child: ListView.builder(
                itemCount: tracks.length,
                controller: controller,
                itemBuilder: (context, index) => TrackTile(
                  track: tracks[index],
                  index: index + 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
