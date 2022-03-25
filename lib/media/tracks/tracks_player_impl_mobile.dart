import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:quiet/component/exceptions.dart';
import 'package:quiet/providers/settings_provider.dart';

import '../../repository.dart';
import 'track_list.dart';
import 'tracks_player.dart';
import 'package:music/music.dart' as player;
import 'package:quiet/extension.dart';

extension _Track on Track {
  player.Music toMusic() {
    var i = imageUrl;
    if (!NetworkSingleton.instance.allowNetwork()) {
      i = null;
    } else if (imageUrl != null && imageUrl!.isEmpty) {
      i = null;
    }

    return player.Music(
        url: file ?? (mp3Url ?? ''), artist: '', title: name, image: i);
  }
}

class TracksPlayerImplMobile extends TracksPlayer {
  TracksPlayerImplMobile() {
    // _player.metadataListenable.addListener(notifyPlayStateChanged);
    // _player.playbackStateListenable.addListener(notifyPlayStateChanged);
    _player = player.MusicPlayer(
        onCompleted: () {
          log('onCompleted');
          _isPlaying = false;
          notifyPlayStateChanged();
        },
        onDuration: (duration) {
          log('onDuration');

          _isBuffing = false;
          _duration = duration;
          notifyPlayStateChanged();
        },
        onLoading: () {
          log('onLoading');
          _isBuffing = true;
          notifyPlayStateChanged();
        },
        onPlaying: () {
          log('onPlaying');
          _isPlaying = true;
          _isBuffing = false;
          notifyPlayStateChanged();
        },
        onPlayNext: () => skipToNext(),
        onError: (e) {
          log('onError');

          _error = true;
          notifyPlayStateChanged();
        },
        onPaused: () {
          log('onPaused');

          _isPlaying = false;
          notifyPlayStateChanged();
        },
        onPlayPrevious: () => skipToPrevious(),
        onPosition: (p) {
          log('onPosition');

          _position = p;
          notifyPlayStateChanged();
        },
        onStopped: () {
          log('onStopped');

          _isPlaying = false;
          notifyPlayStateChanged();
        });
  }

  player.MusicPlayer? _player;

  var _trackList = TrackList.empty();
  Track? _current;
  bool _isPlaying = false;
  bool _error = false;
  bool _isBuffing = false;
  Duration? _position;
  Duration? _duration;

  RepeatMode _mode = RepeatMode.random;

  @override
  Duration? get bufferedPosition => const Duration(milliseconds: 0);

  @override
  Track? get current => _current;

  @override
  Duration? get duration => _duration;

  @override
  Future<void> insertToNext(Track track) async {
    trackList.tracks.add(track);
  }

  @override
  bool get isPlaying => _isPlaying;

  @override
  Future<void> pause() async {
    await _player?.pause();
  }

  Future<void> _play(Track? value) {
    if (value != null) {
      // if (value.mp3Url == null || value.mp3Url!.isEmpty) {
        return networkRepository!.getPlayUrl(value).then((v) {
          value.mp3Url = v.mp3Url;
          log('播放器播放的url=${v.mp3Url.toString()} file=${v.file} ${value.toMusic()}');
          _current = value;
          _player!.play(value.toMusic(), showNext: true, showPrevious: true);
          notifyPlayStateChanged();
        }).catchError((onError){
          if (onError is NetworkException) {
            toast(Intl.message('networkNotAllow'));
            // return Future.error(onError);
          }
          debugPrint('Failed to get play url: ${onError?.toString()}');
          toast(Intl.message('getPlayDetailFail'));
          // return Future.error(onError);
        });
      // } else {
      //   _current = value;
      //   return _player!
      //       .play(value.toMusic(), showNext: true, showPrevious: true)
      //       .then((value) => notifyPlayStateChanged());
      // }
    }
    return Future.error(const QuietException('no track'));
  }

  @override
  Future<void> play() {
    if (_isPlaying) {
      return _player!.resume();
    } else if (_current != null) {
      if (position != null) {
        /// 代表可能此时有进度，不能从头播放
        return _player!.resume();
      } else {
        return _play(_current);
      }
    } else {
      return Future.error(const QuietException('no track'));
    }
  }

  @override
  Future<void> playFromMediaId(int trackId) async {
    // await _player.transportControls.playFromMediaId(trackId.toString());
    final track = trackList.tracks.firstWhereOrNull((t) => t.id == trackId);
    _play(track);
    if (track != null) {
      _play(track);
    } else {
      log('没有track=$trackId list=${trackList.tracks}');
    }
  }

  @override
  double get playbackSpeed => 1;

  @override
  Duration? get position => _position;

  @override
  RepeatMode get repeatMode => _mode;

  @override
  set repeatMode(RepeatMode mode) {
    _mode = mode;
    notifyPlayStateChanged();
  }

  @override
  Future<void> seekTo(Duration position) async {
    _player?.seek(position);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) {
    throw const QuietException('unsupported operator');
  }

  @override
  void setTrackList(TrackList trackList) {
    _trackList = trackList;
  }

  @override
  Future<void> setVolume(double volume) async {
    throw const QuietException('unsupported operator');
  }

  @override
  Future<void> skipToNext() {
    return getNextTrack().then((value) => _play(value));
  }

  @override
  Future<void> skipToPrevious() {
    return getPreviousTrack().then((value) => _play(value));
  }

  @override
  Future<void> stop() {
    return _player!.pause();
  }

  @override
  TrackList get trackList => _trackList;

  @override
  double get volume => 1;

  @override
  bool get isBuffering => _isBuffing;

  @override
  bool get error => _error;
}
