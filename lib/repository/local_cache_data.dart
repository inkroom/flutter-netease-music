import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:track_music_api/track_music_api.dart';

import 'data/playlist_detail.dart';
import 'database.dart';

LocalData neteaseLocalData = LocalData._();

class LocalData {
  LocalData._();

  ///netData 类型必须是可以放入 [store] 中的类型
  static Stream<T> withData<T>(
    String key,
    Future<T> netData, {
    void Function(dynamic e)? onNetError,
  }) async* {
    final data = neteaseLocalData[key];
    if (data != null) {
      final cached = await data;
      if (cached != null) {
        assert(cached is T, "local espect be $T, but is $cached");
        yield cached as T;
      }
    }
    try {
      final net = await netData;
      neteaseLocalData[key] = net;
      yield net;
    } catch (e) {
      if (onNetError != null) onNetError("$e");
      debugPrint('error : $e');
    }
  }

  FutureOr operator [](dynamic key) async {
    return get(key);
  }

  void operator []=(dynamic key, dynamic value) {
    _put(value, key);
  }

  Future<T?> get<T>(dynamic key) async {
    final Database db = await getApplicationDatabase();
    final dynamic result = await StoreRef.main().record(key).get(db);
    if (result is T?) {
      return result;
    }
    assert(false,
        "the result of $key is not subtype of $T. ${result.runtimeType}");
    return null;
  }

  Future _put(dynamic value, [dynamic key]) async {
    final Database db = await getApplicationDatabase();
    final r = StoreRef.main().record(key);
    r.delete(db);
    return r.put(db, value);
  }

  Future<List<PlaylistDetail>> getUserPlaylist(int? userId) async {
    final data = await get("user_playlist_$userId");
    if (data == null) {
      return const [];
    }
    final result = (data as List)
        .cast<Map<String, dynamic>>()
        .map((m) => PlaylistDetail.fromJson(m))
        .toList();
    return result;
  }

  void updateUserPlaylist(int? userId, List<PlaylistDetail?> list) {
    _put(list.map((p) => p!.toJson()).toList(), "user_playlist_$userId");
  }

  Future<PlaylistDetail?> getPlaylistDetail(int playlistId) async {
    final data = await get<Map<String, dynamic>>("playlist_detail_$playlistId");
    if (data == null) {
      return null;
    }
    try {
      return PlaylistDetail.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<String?> downloadMusic(String url, Track track) {
    return getApplicationBin().then((value) {
      final path = join(value.toString(), track.id.toString() + track.name + '.mp3');
      return Dio().download(url, path).then((value) => path);
    });
  }

  //TODO 添加分页加载逻辑
  Future updatePlaylistDetail(PlaylistDetail playlistDetail) {
    return _put(
        playlistDetail.toJson(), 'playlist_detail_${playlistDetail.id}');
  }
}
