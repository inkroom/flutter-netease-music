import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:track_music_api/track_music_api.dart';

/// 基础接口
class KuApi extends MusicApi {
  KuApi(String dir);

  /// 转码
  String _escape2Html(String str) {
    return str
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"');
  }

  @override
  Future<Track> playUrl(Track track) {
    log('hash=${track.extra}');

    return _doRequest(
            'https://wwwapi.kugou.com/yy/index.php?r=play%2Fgetdata&hash=${track.extra}&appid=1014&platid=4&album_id=${track.album?.id}',
            {
              'Cookie':
                  'kg_mid=c64d12df8bef9907d2c2b636167d10a8; kg_dfid=1tyJiN22XC5K3SD5Xz0ojfVx; kg_dfid_collect=d41d8cd98f00b204e9800998ecf8427e'
            },
            {},
            'get')
        .then((value) => value.transform(utf8.decoder).join())
        .then((value) => json.decode(value))
        .then((e) {
      log('歌曲详情=$e');
      if (e['err_code'] != 0) {
        return Future.error(PlayDetailException('获取歌曲详情失败'));
      }
      log('playUrl=${e['data']['play_url']} play_backup_url=${e['data']['play_backup_url']}');
      log('img=${e['data']['img']}');
      return Track(
          id: track.id,
          uri: track.uri,
          mp3Url: e['data']['play_url'] ?? e['data']['play_backup_url'],
          name: track.name,
          artists: track.artists,
          album: track.album,
          imageUrl: e['data']['img'] ?? ' ',
          duration: track.duration,
          type: track.type,
          extra: track.extra,
          origin: origin);
    });
  }

  @override
  Future<PageResult<Track>> search(String keyword, int page, int size) {
    return _doRequest(
            "http://mobilecdn.kugou.com/api/v3/search/song?format=json&keyword=${Uri.encodeComponent(keyword)}&page=${page}&pagesize=${size}&showtype=1",
            {},
            {},
            'get')
        .then((value) => value.transform(utf8.decoder).join())
        .then((value) => json.decode(value))
        .then((value) {
      if (value['status'] != 1) {
        return Future.error(SearchException('搜索失败'));
      }
      log('value=$value');
      final total = value['data']['total'];
      List<Track> list = List.empty(growable: true);
      final s = value['data']['info'] as List;
      log('s=${s}');
      for (var e in s) {
        log('e=$e');

        List<ArtistMini> a = List.empty(growable: true);
        a.add(ArtistMini(id: -1, name: e['singername'], imageUrl: ''));
        log('id = ${e['audio_id']}');
        list.add(Track(
            id: e['audio_id'],
            uri: '',
            name: _escape2Html(e['songname']),
            artists: a,
            album: (e['album_id'] != null && e['album_id'] != '')
                ? AlbumMini(
                    id: int.parse(e['album_id']),
                    name: e['album_name'],
                    picUri: "")
                : null,
            imageUrl: '',
            duration: Duration(seconds: e['duration']),
            type: _convertType(e),
            origin: origin,
            extra: e['hash']));
      }

      return PageResult(data: list, total: total);
    });
  }

  TrackType _convertType(e){
    if(e['privilege'] & 3 == 2 ){
      return TrackType.vip;
    }
    return TrackType.free;
  }


  @override
  int get origin => 2;

  @override
  String get name => "酷狗";

  @override
  String get package => "kugou_api";

  @override
  String get icon => "assets/icon.ico";

  @override
  Future<String?> lyric(Track track) {
    return _doRequest(
            'https://wwwapi.kugou.com/yy/index.php?r=play%2Fgetdata&hash=${track.extra}&appid=1014&platid=4&album_id=${track.album?.id}',
            {
              'Cookie':
                  'kg_mid=c64d12df8bef9907d2c2b636167d10a8; kg_dfid=1tyJiN22XC5K3SD5Xz0ojfVx; kg_dfid_collect=d41d8cd98f00b204e9800998ecf8427e'
            },
            {},
            'get')
        .then((value) => value.transform(utf8.decoder).join())
        .then((value) => json.decode(value))
        .then((e) {
      log('歌词详情==$e');
      if (e['err_code'] != 0) {
        return Future.error(PlayDetailException('获取歌词失败'));
      }
      log('歌词=${e['data']['lyrics']}');
      return Future.value(e['data']['lyrics']);
    });
  }
}

Future<HttpClientResponse> _doRequest(
    String url, Map<String, String> headers, Map data, String method) {
  return HttpClient().openUrl(method, Uri.parse(url)).then((request) {
    headers.forEach(request.headers.add);
    log('query=${Uri(queryParameters: data.cast()).query}');
    request.write(Uri(queryParameters: data.cast()).query);
    return request.close();
  });
}
