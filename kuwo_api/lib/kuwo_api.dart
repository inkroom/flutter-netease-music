import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:track_music_api/track_music_api.dart';

/// 基础接口
class KuWoApi extends MusicApi {
  KuWoApi(String dir);

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
            'http://www.kuwo.cn/api/v1/www/music/playUrl?mid=${track.id}&type=music&httpsStatus=1&reqId=90a70c91-ab46-11ec-878e-1b64bc813d61',
            {
              'Referer': 'http://www.kuwo.cn/play_detail/${track.id}',
              "Cookie": "kw_token=H798KTZAKQD"
            },
            {},
            'get')
        .then((value) => value.transform(utf8.decoder).join())
        .then((value) => json.decode(value))
        .then((e) {
      log('歌曲详情=$e');
      if (e['code'] != 200) {
        return Future.error(PlayDetailException('获取歌曲详情失败'));
      }
      log('playUrl=${e['data']['url']}');
      return Track(
          id: track.id,
          uri: track.uri,
          mp3Url: e['data']['url'],
          name: _escape2Html(track.name),
          artists: track.artists,
          album: track.album,
          imageUrl: track.imageUrl,
          duration: track.duration,
          type: track.type,
          extra: track.extra,
          origin: origin);
    });
  }

  @override
  Future<PageResult<Track>> search(String keyword, int page, int size) {
    return _doRequest(
            "http://www.kuwo.cn/api/www/search/searchMusicBykeyWord?key=${Uri.encodeFull(keyword)}&pn=$page&rn=$size&httpsStatus=1&reqId=3e5b4f20-ab44-11ec-bac5-bfdfcde1c601",
            {
              "Cookie": "kw_token=CUQ9R4J2L4",
              'Referer': 'http://www.kuwo.cn',
              'csrf': 'CUQ9R4J2L4',
              "User-Agent":
                  "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:98.0) Gecko/20100101 Firefox/98.0",
              'Pragma': 'no-cache',
              'Cache-Control': 'no-cache'
            },
            {},
            'get')
        .then((value) => value.transform(utf8.decoder).join())
        .then((value) {
          log('酷我音乐 = $value');
          return value;
        })
        .then((value) => json.decode(value))
        .then((value) {
          if (value['code'] != 200) {
            return Future.error(SearchException('搜索失败'));
          }
          log('value=$value');
          final total = int.parse(value['data']['total']);
          List<Track> list = List.empty(growable: true);
          final s = value['data']['list'] as List;
          for (var e in s) {
            list.add(Track(
                id: int.parse(e['musicrid']
                    .toString()
                    .substring(e['musicrid'].toString().indexOf('_') + 1)),
                uri: '',
                name: _escape2Html(e['name']),
                artists: [
                  ArtistMini(
                      id: e['artistid'], name: e['artist'], imageUrl: e['pic'])
                ],
                album: (e['albumid'] != null && e['albumid'] != '')
                    ? AlbumMini(
                        id: e['albumid'], name: e['album'], picUri: "albumpic")
                    : null,
                imageUrl: '',
                duration: Duration(seconds: e['duration']),
                /// 1111 为付费的
                /// 1100和0000都能播放
                type: e['payInfo']['play'].toString().endsWith("00")
                    ? TrackType.free
                    : TrackType.noCopyright,
                origin: origin,
                extra: e['musicrid']));
          }

          return PageResult(data: list, total: total);
        });
  }

  @override
  int get origin => 3;

  @override
  String get name => "酷我";

  @override
  String get package => "kuwo_api";

  @override
  String get icon => "assets/icon.ico";

  @override
  Future<String?> lyric(Track track) {
    return Future.error(UnsupportedException(''));
    // return _doRequest(
    //         'https://wwwapi.kugou.com/yy/index.php?r=play%2Fgetdata&hash=${track.extra}&appid=1014&platid=4&album_id=${track.album?.id}',
    //         {
    //           'Cookie':
    //               'kg_mid=c64d12df8bef9907d2c2b636167d10a8; kg_dfid=1tyJiN22XC5K3SD5Xz0ojfVx; kg_dfid_collect=d41d8cd98f00b204e9800998ecf8427e'
    //         },
    //         {},
    //         'get')
    //     .then((value) => value.transform(utf8.decoder).join())
    //     .then((value) => json.decode(value))
    //     .then((e) {
    //   log('歌词详情==$e');
    //   if (e['err_code'] != 0) {
    //     return Future.error(PlayDetailException('获取歌词失败'));
    //   }
    //   log('歌词=${e['data']['lyrics']}');
    //   return Future.value(e['data']['lyrics']);
    // });
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
