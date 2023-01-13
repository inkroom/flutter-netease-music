// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackList _$TrackListFromJson(Map json) => TrackList(
      id: json['id'] as String,
      tracks: (json['tracks'] as List<dynamic>)
          .map((e) => Track.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$TrackListToJson(TrackList instance) => <String, dynamic>{
      'id': instance.id,
      'tracks': instance.tracks.map((e) => e.toJson()).toList(),
    };
