import 'package:track_music_api/track_music_api.dart';
const kFmTrackListId = '_fm_playlist';

class TrackList {
  const TrackList({
    required this.id,
    required this.tracks,
  })  : assert(id != kFmTrackListId, 'id should not be $kFmTrackListId'),
        isFM = false;

  TrackList.empty()
      : id = '',
        tracks = List.empty(growable: true),
        isFM = false;

  TrackList.fm({required this.tracks})
      : isFM = true,
        id = kFmTrackListId;

  final String id;
  final List<Track> tracks;

  final bool isFM;
}
