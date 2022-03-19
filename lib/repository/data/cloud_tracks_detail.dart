import 'dart:developer';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quiet/repository.dart';

part 'cloud_tracks_detail.g.dart';

class CloudTrackDetailNotifier extends StateNotifier<CloudTracksDetailState> {
  CloudTrackDetailNotifier()
      : super(const CloudTracksDetailState(
            tracks: [], size: 0, maxSize: 0, trackCount: 0)) {
    _load();
  }
  final _kCacheKey = 'user_cloud_tracks_detail';

  _load() {
    final data = neteaseLocalData.get<Map<String, dynamic>>(_kCacheKey);
    data.then((value) {
      var c = CloudTracksDetail.fromJson(value as Map<String, dynamic>);

      _notify(c.tracks, c.size, c.maxSize, c.trackCount);
    });
  }

  _notify(List<Track> tracks, int size, int maxSize, int trackCount) {
    state = CloudTracksDetailState(
        maxSize: maxSize,
        size: maxSize,
        trackCount: trackCount,
        tracks: tracks);
  }

  _save(List<Track> tracks, int size, int maxSize, int trackCount) {
    var d = CloudTracksDetail(
        tracks: tracks, size: size, maxSize: maxSize, trackCount: trackCount);
    neteaseLocalData[_kCacheKey] = d.toJson();
  }

  add(Track track) {
    var tracks = state.tracks;
    final index = tracks.indexWhere((element) => element.id == track.id);
    if (index == -1) {
      tracks.add(track);
    } else {
      //已存在，可能要进行修改操作
      tracks.setRange(index, index + 1, [track]);
    }
    _save(tracks, 0, 0, tracks.length);
    _notify(tracks, 0, 0, tracks.length);
  }

  remove(Track track) {
    var index = state.tracks.indexWhere((element) => element.id == track.id);
    if (index != -1) {
      state.tracks.removeAt(index);
      _save(state.tracks, 0, 0, state.tracks.length);
      _notify(state.tracks, 0, 0, state.tracks.length);
    }
  }

  /// 文件下载
  /// 下载完成后返回更新后的track
  Future<Track> download(Track track) {
    Future<Track> down() {
      return neteaseRepository!.getPlayUrl(track.id).then((value) {
        /// 下载文件
        track.mp3Url = value.asValue!.value;
        return neteaseLocalData.downloadMusic(value.asValue!.value, track);
      }).then((value) {
        log('下载之后的结果$value');
        track.file = value;
        return Future.value(track);
      });
    }

    // 首先获取权限
    if (Platform.isAndroid) {
      return Permission.storage
          .request()
          .isGranted
          .then((value) => null)
          .then((value) => down());
    } else {
      /// 非安卓直接下载
      return down();
    }
  }
}

@JsonSerializable()
class CloudTracksDetail {
  CloudTracksDetail({
    required this.tracks,
    required this.size,
    required this.maxSize,
    required this.trackCount,
  });

  factory CloudTracksDetail.fromJson(Map<String, dynamic> json) =>
      _$CloudTracksDetailFromJson(json);

  final List<Track> tracks;
  final int size;
  final int maxSize;
  int trackCount;

  Map<String, dynamic> toJson() => _$CloudTracksDetailToJson(this);
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
