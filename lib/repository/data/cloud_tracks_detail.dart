import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/repository.dart';

part 'cloud_tracks_detail.g.dart';

class CloudTrackDetailNotifier extends StateNotifier<CloudTracksDetailState> {
  CloudTrackDetailNotifier()
      : super(const CloudTracksDetailState(
            tracks: [], size: 0, maxSize: 0, trackCount: 0)) {
    _load();
  }

  _load() {
    const kCacheKey = 'user_cloud_tracks_detail';
    final data = neteaseLocalData.get<Map<String, dynamic>>(kCacheKey);
    data.then((value) {
      var c = CloudTracksDetail.fromJson(value as Map<String, dynamic>);

      _notify(c.tracks,c.size,c.maxSize,c.trackCount);
    });
  }

  _notify(List<Track> tracks, int size, int maxSize, int trackCount) {
    state = CloudTracksDetailState(
        maxSize: maxSize,
        size: maxSize,
        trackCount: trackCount,
        tracks: tracks);
  }
}

@JsonSerializable()
class CloudTracksDetail extends StateNotifier<CloudTracksDetailState> {
  CloudTracksDetail({
    required this.tracks,
    required this.size,
    required this.maxSize,
    required this.trackCount,
  }) : super(CloudTracksDetailState(
            tracks: tracks,
            size: size,
            maxSize: maxSize,
            trackCount: trackCount));

  factory CloudTracksDetail.fromJson(Map<String, dynamic> json) =>
      _$CloudTracksDetailFromJson(json);

  final List<Track> tracks;
  final int size;
  final int maxSize;
  int trackCount;

  final _kCacheKey = 'user_cloud_tracks_detail';

  Map<String, dynamic> toJson() => _$CloudTracksDetailToJson(this);

  void addTrack(Track track) {
    tracks.add(track);
    trackCount = tracks.length;
    notify();
  }

  @protected
  void notify() {
    // 存入文件
    neteaseLocalData[_kCacheKey] = toJson();

    state = CloudTracksDetailState(
        maxSize: maxSize,
        size: maxSize,
        trackCount: trackCount,
        tracks: tracks);
  }
}

class CloudTracksDetailState with EquatableMixin {
  const CloudTracksDetailState(
      {required this.tracks,
      required this.size,
      required this.maxSize,
      required this.trackCount});

  final List<Track> tracks;
  final int size;
  final int maxSize;
  final int trackCount;

  @override
  List<Object?> get props => [tracks, size, maxSize, trackCount];
}
