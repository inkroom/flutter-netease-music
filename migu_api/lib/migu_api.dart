import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:track_music_api/track_music_api.dart';

/// 基础接口
class MiGuApi extends MusicApi {
  MiGuApi(String dir);

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
    log('copyrightId=${track.extra}');

    return _doRequest(
            'https://c.musicapp.migu.cn/MIGUM2.0/v1.0/content/resourceinfo.do?copyrightId=${track.extra}&resourceType=2',
            {
              'Referer': 'http://m.music.migu.cn/v3',
            },
            {},
            'get')
        .then((value) => value.transform(utf8.decoder).join())
        .then((value) => json.decode(value))
        .then((e) {
      log('歌曲详情=$e');
      if (e['code'] != "000000") {
        return Future.error(PlayDetailException('获取歌曲详情失败'));
      }

      final rs = e['resource'] as List;
      if (rs.isEmpty) {
        return Future.error(PlayDetailException('获取歌曲详情失败'));
      }
      final r = rs[0];

      final rates = r['rateFormats'] as List;
      if (rates.isEmpty) {
        return Future.error(PlayDetailException('获取歌曲详情失败'));
      }
      return Track(
          id: track.id,
          uri: track.uri,
          mp3Url: rates[0]['url'].toString().replaceFirst(
              RegExp("ftp://[^/]+"), "https://freetyst.nf.migu.cn"),
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
            "https://m.music.migu.cn/migu/remoting/scr_search_tag?keyword=${Uri.encodeFull(keyword)}&pgc=$page&rows=$size&type=2",
            {
              'Referer': 'http://m.music.migu.cn/v3',
            },
            {},
            'get')
        .then((value) => value.transform(utf8.decoder).join())
        .then((value) {
          log('咪咕音乐 = $value');
          return value;
        })
        .then((value) => json.decode(value))
        .then((value) {
          if (!value['success']) {
            return Future.error(SearchException('搜索失败'));
          }
          log('value=$value');
          final total = value['pgt'];
          List<Track> list = List.empty(growable: true);
          final s = value['musics'] as List;
          for (var e in s) {
            List<ArtistMini> arts = List.empty(growable: true);
            if(e['singerId'] != null && e['singerId'].toString().isNotEmpty){
              final singerIds = e['singerId'].toString().split(", ");
              final singerNames = e['artist'].toString().split(", ");
              for (var i = 0; i < singerIds.length; i++) {
                arts.add(ArtistMini(
                    id: int.parse(singerIds[i].toString()),
                    name: singerNames[i],
                    imageUrl: ''));
              }
            }

            list.add(Track(
                id: int.parse(e['id']),
                uri: '',
                name: _escape2Html(e['songName']),
                artists: arts,
                album: (e['albumId'] != null && e['albumId'] != '')
                    ? AlbumMini(
                        id: int.parse(e['albumId']),
                        name: e['albumName'],
                        picUri: e['cover'])
                    : null,
                imageUrl: e['cover'],
                duration: const Duration(seconds: 0),
                type: (e['mp3'] == null || e['mp3'].toString().isEmpty)
                    ? TrackType.noCopyright
                    : TrackType.free,
                origin: origin,
                extra: e['copyrightId']));
          }

          return PageResult(data: list, total: total);
        });
  }

  @override
  int get origin => 4;

  @override
  String get name => "咪咕";

  @override
  String get package => "migu_api";

  @override
  String get icon => "assets/icon.ico";

  @override
  Future<String?> lyric(Track track) {
    log("歌词 extra = ${track.extra}");

    return _doRequest(
            'http://music.migu.cn/v3/api/music/audioPlayer/getLyric?copyrightId=${track.extra}',
            {
              'Referer': 'http://m.music.migu.cn/v3',
            },
            {},
            'get')
        .then((value) => value.transform(utf8.decoder).join())
        .then((value) {
          log('咪咕获取歌词 = $value');
          return value;
        })
        .then((value) => json.decode(value))
        .then((e) {
          log('歌词详情==$e');
          if (e['returnCode'] != '000000') {
            return Future.error(PlayDetailException('获取歌词失败'));
          }
          log('歌词=${e['lyric']}');
          return Future.value(e['lyric']);
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
