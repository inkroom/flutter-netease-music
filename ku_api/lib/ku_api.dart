import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:track_music_api/track_music_api.dart';

/// 基础接口
class KuApi extends MusicApi {
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
    return _doRequest('https://wwwapi.kugou.com/yy/index.php', {},
            {'r': 'play/getdata', 'hash': track.extra}, 'get')
        .then((value) => value.cast().transform(utf8.decoder).join())
        .then((value) => json.decode(value))
        .then((e) {
      return Track(
          id: track.id,
          uri: e['data']['play_url'],
          name: track.name,
          artists: track.artists,
          album: track.album,
          imageUrl: e['data']['img'],
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
        .then((value) => value.cast().transform(utf8.decoder).join())
        .then((value) => json.decode(value))
        .then((value) {
      final total = value['data']['total'];
      List<Track> list = List.empty(growable: true);
      final s = value['data']['lists'] as List;

      for (var e in s) {
        final art = e['Grp']['Singers'] as List;

        List<ArtistMini> a = List.empty(growable: true);
        for (var e in art) {
          a.add(ArtistMini(id: e.id, name: e.name, imageUrl: ''));
        }

        list.add(Track(
            id: e.Audioid,
            uri: '',
            name: e.SongName,
            artists: a,
            album: AlbumMini(id: e.AlbumID, name: e.AlbumName, picUri: ""),
            imageUrl: '',
            duration: Duration(seconds: e.Duration),
            type: TrackType.free,
            origin: origin,
            extra: e.FileHash));
      }

      return PageResult(data: list, total: total);
    });
  }

  @override
  int get origin => 2;
}

Future<HttpClientResponse> _doRequest(
    String url, Map<String, String> headers, Map data, String method) {
  return HttpClient().openUrl(method, Uri.parse(url)).then((request) {
    headers.forEach(request.headers.add);
    request.write(Uri(queryParameters: data.cast()).query);
    return request.close();
  });
}
