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

  final Dio _dio = Dio();

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
    _put(value, key).catchError((onError, stacktrace) {
      log('数据保存失败=$key $value  $onError $stacktrace');
    });
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
    final name = _resolveName(track);
    log('文件下载，url=$url 文件名=$name');
    return getApplicationBin().then((value) {
      final path = join(value.toString(), name);
      return _dio.download(url, path).then((value) => path);
    });
  }

  Future<Map<String, dynamic>?> getPlaying() {
    return get<Map<String, dynamic>>("_playing_track_");
  }

  void savePlaying(Map<String, dynamic> json) {
    _put(json, "_playing_track_");
  }

  /// 获取文件名
  ///
  /// windows限制为
  /// 1.1) 以下字符不能出现在文件和文件夹名称中：（引号之内）
  /// '/'  '?'  '*'  ':'  '|'  '\'  '<'  '>'
  /// 1.2) 以下字符不能命名为文件或文件夹的名称：（引号之内）
  /// "con","aux","nul","prn","com0","com1","com2","com3","com4","com5","com6","com7"
  /// "com8","com9","lpt0","lpt1","lpt2","lpt3","lpt4","lpt5","lpt6","lpt7","lpt8","lpt9"
  /// 1.3) 另外，由于Windows对全文件名的字符长度作出258个字符以内的限制。全文件名长度指的是包括了文件路径的全部长度（一个汉字也按一个字符计算）。
  ///
  ///  Linux限制为
  /// 2.1) 除了 / 之外，所有的字符都合法。
  /// 2.2) 有些字符最好不用，如空格符、制表符、退格符和字符 @ # $ & ( ) - 等。
  /// 2.3) 避免使用加减号或 . 作为普通文件名的第一个字符。
  /// 2.4) 大小写敏感。
  /// 2.5) Linux 系统下的文件名长度最多可到256个字符。
  ///
  /// Uninx限制为
  /// 3.1）最多 255 个字符，除了字符 / 及空格其余均可。
  ///
  ///
  /// Android限制为
  ///
  /// 任何字节除了值0-31,127（DEL）和：“* /：<>？\ | +，。; = []（低位az存储为AZ）。使用VFAT LFN除NUL之外的任何Unicode
  ///
  String _resolveName(Track track) {
    /// 最好文件名要能全平台通用，

    return "${track.id.toString()}${track.extra}${track.name}.mp3"
        .replaceAll("/", "")
        .replaceAll("\\", "")
        .replaceAll("*", "")
        .replaceAll(">", "")
        .replaceAll("<", "")
        .replaceAll(":", "")
        .replaceAll("|", "")
        .replaceAll("?", "")
        .replaceAll("+", "")
        .replaceAll("=", "")
        .replaceAll("[", "")
        .replaceAll("]", "")
        .replaceAll('"', "");
  }

  //TODO 添加分页加载逻辑
  Future updatePlaylistDetail(PlaylistDetail playlistDetail) {
    return _put(
        playlistDetail.toJson(), 'playlist_detail_${playlistDetail.id}');
  }
}
