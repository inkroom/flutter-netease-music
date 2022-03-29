import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component/exceptions.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/repository.dart';

import 'track_list.dart';
import 'tracks_player.dart';

extension _SecondsToDuration on double {
  Duration toDuration() {
    return Duration(milliseconds: (this * 1000).round());
  }
}

class TracksPlayerImplVlc extends TracksPlayer {
  TracksPlayerImplVlc() {
    _player.playbackStream.listen((event) {
      if (event.isCompleted) {
        skipToNext();
      }
      notifyPlayStateChanged();
    });
    _player.generalStream.listen((event) => notifyPlayStateChanged());
  }

  final _player = Player(
    id: 0,
    commandlineArguments: ['--no-video'],
  );

  var _trackList = TrackList.empty();

  Track? _current;

  RepeatMode _mode = RepeatMode.random;

  @override
  Duration? get bufferedPosition => _player.bufferingProgress.toDuration();

  @override
  Track? get current => _current;

  @override
  Duration? get duration => _player.position.duration;

  @override
  Future<Track?> getPreviousTrack() async {
    final index = _trackList.tracks.cast().indexOf(current);
    if (index == -1) {
      return _trackList.tracks.lastOrNull;
    }
    final previousIndex = index - 1;
    if (previousIndex < 0) {
      return null;
    }
    return _trackList.tracks[previousIndex];
  }

  @override
  Future<void> insertToNext(Track track) async {
    final index = _trackList.tracks.cast().indexOf(current);
    // if (index == -1) {
    // return;
    // }
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
  bool get isPlaying => _player.playback.isPlaying;

  @override
  Future<void> pause() async {
    _player.pause();
  }

  @override
  Future<void> play() async {
    _player.play();
  }

  @override
  Future<void> playFromMediaId(int trackId) async {
    stop();
    final item = _trackList.tracks.firstWhereOrNull((t) => t.id == trackId);
    if (item != null) {
      _playTrack(item);
    }
  }

  @override
  double get playbackSpeed => _player.general.rate;

  @override
  Duration? get position => _player.position.position;

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
    _player.setRate(speed);
  }

  @override
  void setTrackList(TrackList trackList) {
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
  double get volume => _player.general.volume;

  void _playTrack(Track track) {
    // scheduleMicrotask(() {
    if (track.file != null) {
      log('从文件播放${track.file}');
      _current = track;
      notifyPlayStateChanged();
      _player.open(Media.file(File(track.file!)), autoStart: true);
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
            _player.open(Media.network(value.mp3Url), autoStart: true);
            return value;
          }
          toast(Intl.message('getPlayDetailFail'));

          return Future.error(PlayDetailException);
        }).catchError((onError) {
          if (onError is NetworkException) {
            toast(Intl.message('networkNotAllow'));
            return Future.error(onError);
          }
          debugPrint('Failed to get play url: ${onError?.toString()}');
          toast(Intl.message('getPlayDetailFail'));
          return Future.error(onError);
        });
      });
    }
  }

  @override
  bool get error => false;
}
