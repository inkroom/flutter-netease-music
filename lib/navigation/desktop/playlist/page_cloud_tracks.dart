import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/navigation/common/navigation_target.dart';
import 'package:quiet/navigation/common/playlist/music_list.dart';
import 'package:quiet/navigation/desktop/widgets/track_tile_normal.dart';
import 'package:quiet/providers/navigator_provider.dart';
import 'package:quiet/repository.dart';

import '../../../providers/cloud_tracks_provider.dart';
import '../../../providers/player_provider.dart';

class PageCloudTracks extends ConsumerWidget {
  const PageCloudTracks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(cloudTracksProvider);


    return Material(
      color: context.colorScheme.background,
      child:  _PageCloudTracksBody(detail: result)
    );
  }
}

class _PageCloudTracksBody extends ConsumerWidget {
  const _PageCloudTracksBody({
    Key? key,
    required this.detail,
  }) : super(key: key);

  final CloudTracksDetailState detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TrackTileContainer.cloudTracks(
      tracks: detail.tracks,
      player: ref.read(playerProvider),
      child: TrackTableContainer(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _UserCloudInformation(detail: detail),
            const SizedBox(height: 20),
            const TrackTableHeader(),
            Expanded(
              child: _DropUploadArea(
                child: ListView.builder(
                  itemCount: detail.tracks.length,
                  itemBuilder: (context, index) {
                    final track = detail.tracks[index];
                    return TrackTile(track: track, index: index + 1);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCloudInformation extends StatelessWidget {
  const _UserCloudInformation({
    Key? key,
    required this.detail,
  }) : super(key: key);

  final CloudTracksDetailState detail;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: context.textTheme.caption!,
      child: Row(
        children: [
          const SizedBox(width: 20),
          Text(context.strings.cloudMusicUsage),
          const SizedBox(width: 8),
          Text(detail.trackCount.toString()),
          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _DropUploadArea extends HookConsumerWidget {
  const _DropUploadArea({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enable = ref.watch(navigatorProvider
        .select((value) => value.current is NavigationTargetCloudMusic));
    final dragging = useState(false);
    return DropTarget(
      child: Stack(
        children: [
          child,
          if (dragging.value)
            DecoratedBox(
              decoration: BoxDecoration(color: context.colorScheme.surface),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DottedBorder(
                  color: context.colorScheme.onSurface,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(8),
                  child: Center(
                    child: Text(
                      context.strings.cloudMusicFileDropDescription,
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      enable: enable,
      onDragEntered: (details) => dragging.value = true,
      onDragExited: (details) => dragging.value = false,
      onDragDone: (details) {
        dragging.value = false;
        // TODO upload file.
        debugPrint('onDragDone: ${details.files.length}');
      },
    );
  }
}
