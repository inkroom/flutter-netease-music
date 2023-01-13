// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracks_player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TracksPlayerState _$TracksPlayerStateFromJson(Map json) => TracksPlayerState(
      isBuffering: json['isBuffering'] as bool,
      isPlaying: json['isPlaying'] as bool,
      playingTrack: json['playingTrack'] == null
          ? null
          : Track.fromJson(
              Map<String, dynamic>.from(json['playingTrack'] as Map)),
      playingList: TrackList.fromJson(json['playingList'] as Map),
      duration: json['duration'] == null
          ? null
          : Duration(microseconds: json['duration'] as int),
      volume: (json['volume'] as num).toDouble(),
      mode: $enumDecode(_$RepeatModeEnumMap, json['mode']),
      error: json['error'] as bool,
      position: json['position'] == null
          ? null
          : Duration(microseconds: json['position'] as int),
    );

Map<String, dynamic> _$TracksPlayerStateToJson(TracksPlayerState instance) =>
    <String, dynamic>{
      'isBuffering': instance.isBuffering,
      'isPlaying': instance.isPlaying,
      'playingTrack': instance.playingTrack?.toJson(),
      'playingList': instance.playingList.toJson(),
      'duration': instance.duration?.inMicroseconds,
      'position': instance.position?.inMicroseconds,
      'volume': instance.volume,
      'mode': _$RepeatModeEnumMap[instance.mode],
      'error': instance.error,
    };

const _$RepeatModeEnumMap = {
  RepeatMode.all: 'all',
  RepeatMode.one: 'one',
  RepeatMode.none: 'none',
  RepeatMode.random: 'random',
  RepeatMode.next: 'next',
};
