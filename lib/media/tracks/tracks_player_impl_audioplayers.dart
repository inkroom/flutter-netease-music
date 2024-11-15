import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/component/exceptions.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/material.dart';
import 'package:quiet/repository.dart';

import 'track_list.dart';
import 'tracks_player.dart';

extension _SecondsToDuration on double {
  Duration toDuration() {
    return Duration(milliseconds: (this * 1000).round());
  }
}

class TracksPlayerImplAudioPlayer extends TracksPlayer {
  TracksPlayerImplAudioPlayer(StateNotifierProviderRef ref) : super(ref) {
    _player.onDurationChanged.listen((Duration event) {
      _duration = event;
      notifyPlayStateChanged();
    });
    _player.onPlayerStateChanged.listen((PlayerState s) {
      _playerState = s;
      notifyPlayStateChanged();
    });
    _player.onPlayerComplete.listen((event) {
      skipToNext();
    });
    _player.onPositionChanged.listen((Duration d) {
      _position = d;
      notifyPlayStateChanged();
    });
  }

// playbackStream -> positionStream ->  generalStream -> currentStream | positionStream ->  playbackStream
  final _player = AudioPlayer();

  var _trackList = TrackList.empty();

  Track? _current;

  Duration? _duration;
  Duration? _position;
  double _volume = 1;

  PlayerState? _playerState;

  RepeatMode _mode = RepeatMode.random;

  @override
  Duration? get bufferedPosition => const Duration();

  @override
  Track? get current => _current;

  @override
  Duration? get duration {
    if (_current != null && _current!.duration.inSeconds != 0) {
      /// 考虑到部分数据源可能没有时长数据，因此不能完全依靠该字段
      return _current!.duration;
    }
    return _duration;
  }

  @override
  Future<void> insertToNext(Track track) async {
    final index = _trackList.tracks.cast().indexOf(current);
    final nextIndex = index + 1;
    if (nextIndex >= _trackList.tracks.length) {
      _trackList.tracks.add(track);
    } else {
      final next = _trackList.tracks[nextIndex];
      if (next != track) {
        _trackList.tracks.insert(nextIndex, track);
      }
    }
    notifyPlayStateChanged();
  }

  @override
  bool get isBuffering => false;

  @override
  bool get isPlaying => _playerState == PlayerState.playing;

  @override
  Future<void> pause() async {
    _player.pause();
  }

  @override
  Future<void> play() async {
    _player.resume();
  }

  @override
  Future<void> playFromMediaId(int trackId) async {
    stop();
    final item = _trackList.tracks.firstWhereOrNull((t) => t.id == trackId);
    if (item != null) {
      _playTrack(item);
    }
  }

  double _playbackSpeed = 1;

  @override
  double get playbackSpeed => _playbackSpeed;

  Duration? _startPosition;

  @override
  Duration? get position {
    // 当开始位置不为0，且player获取的位置为0时，返回开始位置；一旦player的位置不为0，那就直接丢弃开始位置，以player位置为准；因为一旦不为0，说明音乐已经播放过了，最开始的播放位置已经没有用了
    if (_startPosition != null &&
        _position != null &&
        _position!.inSeconds == 0) {
      return _startPosition;
    }
    _startPosition = null;
    return _position;
  }

  @override
  RepeatMode get repeatMode => _mode;

  @override
  set repeatMode(RepeatMode mode) {
    _mode = mode;
    notifyPlayStateChanged();
  }

  @override
  Future<void> seekTo(Duration position) async {
    _player.seek(position);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    _player.setPlaybackRate(speed);
  }

  @override
  void setTrackList(TrackList trackList) {
    super.setTrackList(trackList);
    bool needStop = trackList.id != _trackList.id;
    if (needStop) {
      stop();
      _current = null;
    }
    _trackList = trackList;
    notifyPlayStateChanged();
  }

  @override
  Future<void> setVolume(double volume) async {
    _player.setVolume(volume);
    _volume = volume;
    notifyPlayStateChanged();
  }

  @override
  Future<void> skipToNext() {
    return getNextTrack().then((value) {
      if (value != null) {
        _playTrack(value);
      }
    });
  }

  @override
  Future<void> skipToPrevious() async {
    getPreviousTrack().then((value) {
      if (value != null) {
        _playTrack(value);
      }
    });
  }

  @override
  Future<void> stop() async {
    _player.stop();
  }

  @override
  TrackList get trackList => _trackList;

  @override
  double get volume => _volume;

  void _playTrack(Track track, {bool autoStart = true, Duration? position}) {
    // scheduleMicrotask(() {
    if (track.file != null) {
      log('从文件播放${track.file}');
      _current = track;
      if (autoStart) {
        _player.play(DeviceFileSource(track.file!), position: position);
      } else {
        _player.setSourceDeviceFile(track.file!).then((value) {
          if (_position != null) _player.seek(position!);
          return value;
        });
      }
      notifyPlayStateChanged();
      // 加入播放历史
      played.add(track);
    } else {
      if (_current == track) {
        // skip play. since the track is changed.
        return;
      }
      scheduleMicrotask(() {
        final url = networkRepository!.getPlayUrl(track);

        url.then((value) {
          log('获取的播放uri=${value.toString()}');
          if (value.mp3Url != null && value.mp3Url!.isNotEmpty) {
            log('url=${value.mp3Url}');
            _current = track;
            notifyPlayStateChanged();

            /// startTime 参数可以设置开始播放位置，但是不会更新 player 的position，还需要自己设置
            if (autoStart) {
              _player.play(UrlSource(value.mp3Url!), position: position);
            } else {
              _player.setSourceUrl(value.mp3Url!).then((value) {
                if (_position != null) _player.seek(position!);
                return value;
              });
            }
            // 加入播放历史
            played.add(track);
            return value;
          }
          toast(S.current.getPlayDetailFail);
          return Future.error(PlayDetailException);
        }).catchError((onError) {
          if (onError is NetworkException) {
            toast(S.current.networkNotAllow);
            return Future.value(
                onError); // 调用 Future.error 会提示 Unhandled，，不返回又要提示 需要一个返回值。
          }
          debugPrint('Failed to get play url: ${onError?.toString()}');
          toast(S.current.getPlayDetailFail);
          return Future.value(
              onError); // 调用 Future.error 会提示 Unhandled，，不返回又要提示 需要一个返回值。
        });
      });
    }
  }

  @override
  void load(TracksPlayerState state, {bool autoStart = false}) {
    if (state.playingTrack != null) {
      setTrackList(state.playingList);
      setVolume(state.volume);
      repeatMode = state.mode;
      _startPosition = state.position;

      /// 根据配置处理项
      _playTrack(state.playingTrack!,
          autoStart: autoStart, position: state.position);
    }
  }

  @override
  bool get error => false;
}
