import 'dart:io';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repository/data/track.dart';
import 'track_list.dart';
import 'tracks_player_impl_mobile.dart';
import 'tracks_player_impl_vlc.dart';

enum RepeatMode {
  /// Repeat all the tracks.
  all,

  /// Repeat the current track.
  one,

  /// Do not repeat any tracks.
  none,

  /// 随机播放
  random,

  /// 当前的下一首
  next,
}

class TracksPlayerState with EquatableMixin {
  const TracksPlayerState({
    required this.isBuffering,
    required this.isPlaying,
    required this.playingTrack,
    required this.playingList,
    required this.duration,
    required this.volume,
    required this.mode,
  });

  final bool isBuffering;
  final bool isPlaying;
  final Track? playingTrack;
  final TrackList playingList;
  final Duration? duration;
  final double volume;
  final RepeatMode mode;

  @override
  List<Object?> get props => [
        isPlaying,
        isBuffering,
        playingTrack,
        playingList,
        duration,
        volume,
        mode,
      ];
}

abstract class TracksPlayer extends StateNotifier<TracksPlayerState> {
  TracksPlayer()
      : super(TracksPlayerState(
            isPlaying: false,
            isBuffering: false,
            playingTrack: null,
            playingList: TrackList.empty(),
            duration: null,
            volume: 0.0,
            mode: RepeatMode.random));

  factory TracksPlayer.platform() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return TracksPlayerImplVlc();
    }
    return TracksPlayerImplMobile();
  }

  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> seekTo(Duration position);

  Future<void> setVolume(double volume);

  Future<void> setPlaybackSpeed(double speed);

  Future<void> skipToNext();

  Future<void> skipToPrevious();

  Future<void> playFromMediaId(int trackId);

  void setTrackList(TrackList trackList);

  /// 获取要播放的下一首音乐
  Future<Track?> getNextTrack() {
    final index = trackList.tracks.cast().indexOf(current);
    if (repeatMode == RepeatMode.next) {
      // 直接播放下一首
      if (index == -1 || index == trackList.tracks.length - 1) {
        return Future.value(trackList.tracks.first);
      }
      return Future.value(trackList.tracks[index + 1]);
    } else if (repeatMode == RepeatMode.random) {
      // 随机播放
      return Future.value(
          trackList.tracks[Random().nextInt(trackList.tracks.length)]);
    } else if (repeatMode == RepeatMode.none) {
      // 单曲循环
      return Future.value(current);
    }
    return Future.value(null);
  }

  Future<Track?> getPreviousTrack() {
    final index = trackList.tracks.cast().indexOf(current);
    if (repeatMode == RepeatMode.next) {
      // 直接播放上一首
      if (index == -1 || index == 0) {
        return Future.value(trackList.tracks.first);
      }
      return Future.value(trackList.tracks[index - 1]);
    } else if (repeatMode == RepeatMode.random) {
      // 随机播放
      return Future.value(
          trackList.tracks[Random().nextInt(trackList.tracks.length)]);
    } else if (repeatMode == RepeatMode.none) {
      // 单曲循环
      return Future.value(current);
    }
    return Future.value(null);
  }

  Future<void> insertToNext(Track track);

  Track? get current;

  TrackList get trackList;

  RepeatMode get repeatMode;

  /// 设置下一首模式
  set repeatMode(RepeatMode mode);

  bool get isPlaying;

  bool get isBuffering;

  Duration? get position;

  Duration? get duration;

  Duration? get bufferedPosition;

  double get volume;

  double get playbackSpeed;

  @protected
  void notifyPlayStateChanged() {
    state = TracksPlayerState(
      isPlaying: isPlaying,
      isBuffering: isBuffering,
      playingTrack: current,
      playingList: trackList,
      duration: duration,
      volume: volume,
      mode: repeatMode,
    );
  }
}
