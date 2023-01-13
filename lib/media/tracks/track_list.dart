import 'package:json_annotation/json_annotation.dart';
import 'package:track_music_api/track_music_api.dart';

part 'track_list.g.dart';

const kFmTrackListId = '_fm_playlist';

@JsonSerializable()
class TrackList {
  const TrackList({
    required this.id,
    required this.tracks,
  })  : assert(id != kFmTrackListId, 'id should not be $kFmTrackListId'),
        isFM = false;

  factory TrackList.fromJson(Map json) => _$TrackListFromJson(json);

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

  Map<String, dynamic> toJson() => _$TrackListToJson(this);
}
