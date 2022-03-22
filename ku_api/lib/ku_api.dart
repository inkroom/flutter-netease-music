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

    // final d = Dio();
    // d.interceptors.add(LogInterceptor());
    // d.interceptors.add(CookieManager(PersistCookieJar(ignoreExpires: true)));
    // d.get('https://wwwapi.kugou.com/yy/index.php', queryParameters: {
    //   'r': 'play/getdata',
    //   'hash': track.extra
    // }).then((res) => {log('dio=$res')});
    return _doRequest(
            'https://wwwapi.kugou.com/yy/index.php?r=play%2Fgetdata&hash=${track.extra}',
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
      if (e['status'] != 1) {
        return Future.error(PlayDetailException('获取歌曲详情失败'));
      }
      log('playUrl=${e['data']['play_url']}');
      log('img=${e['data']['img']}');
      return Track(
          id: track.id,
          uri: track.uri,
          mp3Url: e['data']['play_url'] ?? '',
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
            "https://songsearch.kugou.com/song_search_v2?pagesize=$size&keyword=$keyword&page=$page",
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
      final s = value['data']['lists'] as List;
      log('s=${s}');
      for (var e in s) {
        log('e=$e');
        final art = e['Singers'] as List;

        log('art=$art');

        List<ArtistMini> a = List.empty(growable: true);
        for (var e in art) {
          a.add(ArtistMini(id: e['id'], name: e['name'], imageUrl: ''));
        }

        list.add(Track(
            id: e['Audioid'],
            uri: '',
            name: _escape2Html(e['SongName']),
            artists: a,
            album: (e['AlbumID'] != null && e['AlbumID'] != '')
                ? AlbumMini(
                    id: int.parse(e['AlbumID']),
                    name: e['AlbumName'],
                    picUri: "")
                : null,
            imageUrl: '',
            duration: Duration(seconds: e['Duration']),
            type: TrackType.free,
            origin: origin,
            extra: e['FileHash']));
      }

      return PageResult(data: list, total: total);
    });
  }

  @override
  int get origin => 2;

  @override
  String get name => "酷狗";
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
