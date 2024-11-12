import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:track_music_api/track_music_api.dart';

const COOKIE_NAME = "Hm_Iuvt_cdb524f42f23cer9b268564v7y735ewrq2324";

class KuWoApi extends MusicApi {
  KuWoApi(String dir);

  String? cookie;

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
    return _doRequest(
            'https://www.kuwo.cn/api/v1/www/music/playUrl?mid=${track.id}&type=music&httpsStatus=1',
            {
              "Secret": _getSecret(cookie ?? "", COOKIE_NAME),
              // 'Referer': 'http://www.kuwo.cn/play_detail/${track.id}',
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36 Edg/115.0.1901.188',
              'Pragma': 'no-cache',
              'Cache-Control': 'no-cache'
            },
            {},
            'get')
        .then((value) => value.transform(utf8.decoder).join())
        .then((value) => json.decode(value))
        .then((e) {
      dev.log('歌曲详情=$e');
      if (e['code'] != 200) {
        if (e['msg'].toString().contains("付费")) {
          return Future.error(PlayDetailException(
              '付费歌曲',
              Track(
                  id: track.id,
                  uri: track.uri,
                  mp3Url: '',
                  name: _escape2Html(track.name),
                  artists: track.artists,
                  album: track.album,
                  imageUrl: track.imageUrl,
                  duration: track.duration,
                  type: TrackType.vip,
                  extra: track.extra,
                  origin: origin)));
        }
        return Future.error(PlayDetailException('获取歌曲详情失败 ', track));
      }
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
            "https://www.kuwo.cn/search/searchMusicBykeyWord?vipver=1&client=kt&ft=music&cluster=0&strategy=2012&encoding=utf8&rformat=json&mobi=1&issubtitle=1&show_copyright_off=1&pn=${page - 1}}&rn=$size&all=${Uri.encodeFull(keyword)}",
            {},
            {},
            'get')
        .then((value) => value.transform(utf8.decoder).join())
        .then((value) => json.decode(value))
        .then((value) {
      // if (value['abslist'] != 200) {
      //   return Future.error(SearchException('搜索失败'));
      // }
      final total = int.parse(value['TOTAL']);
      List<Track> list = List.empty(growable: true);
      final s = value['abslist'] as List;
      for (var e in s) {
        list.add(Track(
            id: int.parse(e['DC_TARGETID']),
            uri: '',
            name: (e['NAME']),
            artists: [
              ArtistMini(
                  id: int.parse(e['ARTISTID']),
                  name: e['ARTIST'],
                  imageUrl: e['hts_MVPIC'])
            ],
            album: (e['ALBUMID'] != null && e['ALBUMID'] != '')
                ? AlbumMini(
                    id: int.parse(e['ALBUMID']),
                    name: e['ALBUM'],
                    picUri: e["hts_MVPIC"])
                : null,
            imageUrl: e["hts_MVPIC"],
            duration: Duration(seconds: int.parse(e['DURATION'])),

            /// 搜索的时候无法判断是否可以播放，只能推迟到播放的时候
            type: TrackType.free,
            origin: origin,
            extra: e['DC_TARGETID']));
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

  String _formatDuration(Duration v) {
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    String mill = duration.inMilliseconds
        .remainder(1000)
        .toString()
        .padRight(3, '0')
        .substring(0, 3);
    return "$minutes:$seconds.$mill";
  }

  @override
  Future<LyricContent?> lyric(Track track) {
    return _doRequest(
            "https://www.kuwo.cn/openapi/v1/www/lyric/getlyric?musicId=${track.id}&httpsStatus=1",
            {},
            {},
            'get')
        .then((value) => value.transform(utf8.decoder).join())
        .then((value) => json.decode(value))
        .then((value) {
      if (value['code'] != 200) {
        return Future.error(LyricException('获取歌词失败'));
      }
/*
{
    "code": 200,
    "msg": "success",
    "reqId": "b53df35a992fb8c299ac0338fb2f654d",
    "data": {
        "lrclist": [
            {
                "lineLyric": "Hello - Adele",
                "time": "268.44"
            }
        ]
    },
    "profileId": "site",
    "curTime": 1731403015553,
    "success": true
}*/

      return Future.value(
          LyricContent.from((value['data']['lrclist'] as List).map((v) {
        return '[' +
            _formatDuration(Duration(
                milliseconds: (double.parse(v['time']) * 1000).toInt())) +
            ']' +
            v['lineLyric'].toString();
      }).join("\n")));
    });
  }

  Future<HttpClientResponse> _doRequest(
      String url, Map<String, String> headers, Map data, String method) {
    return HttpClient().openUrl(method, Uri.parse(url)).then((request) {
      headers.forEach(request.headers.add);
      if (cookie != null) {
        request.headers.add("Cookie", COOKIE_NAME + "=" + cookie!);
      }
      request.write(Uri(queryParameters: data.cast()).query);
      return request.close();
    }).then((res) {
      // 保存cookie
      cookie = res.cookies.where((c) => c.name == COOKIE_NAME).map((c) {
        return c.value;
      }).join("; ");
      return res;
    });
  }

  String _getV(int l, String v) {
    if (l >= v.length) {
      return "";
    }
    return v[l];
  }

  BigInt _parseBigInt(String v) {
// 模拟 js parseInt 效果，当v中出现非数字，忽略后面所有值
    String m = v;
    for (var i = 0; i < v.length; i++) {
      var h = (v.codeUnitAt(i));
      if (h < 48 || h >= 58) {
        m = v.substring(0, i);
        break;
      }
    }
    return BigInt.parse(m);
  }

  String _bigIntToString(BigInt v) {
// 模拟 js toString 效果，当数字长度超过21时，使用科学计数法
    var s = v.toString();
    var out = v.toString();
    if (s.length > 21) {
      out = s[0] + "." + s.substring(1, min(16, s.length));
      if (s.length > out.length) {
        // 四舍五入
        if (s.codeUnitAt(out.length) >= 53) {
          // 最后一位 + 1
          out += (int.parse(s[out.length - 1]) + 1).toString();
        } else {
          out += s[out.length - 1];
        }
      }

      out += "e+" + (s.length - 1).toString();
    }

    return out;
  }

  String _getSecret(String value, String name) {
    // 获取 unicode 编码，因为n都在ascii内，所以就是获取ascii码
    String n = "";
    for (var i = 0; i < name.length; i++) {
      n += name.codeUnitAt(i).toString();
    }
    var o = (n.length / 5).floor();
    var r = int.parse(_getV(o, n) +
        _getV(2 * o, n) +
        _getV(3 * o, n) +
        _getV(4 * o, n) +
        _getV(5 * o, n));
    var c = (name.length / 2).ceil();
    var l = pow(2, 31) - 1;
    if (r < 2) return "";
    var d = ((1e9 * Random().nextDouble()).round() % 1e8).toInt();
    for (n += d.toString(); n.length > 10;) {
      n = _bigIntToString(_parseBigInt(n.substring(0, 10)) +
          _parseBigInt(n.substring(10, n.length)));
    }
    var nn = (r * int.parse(n) + c) % l;
    var f = 1;
    var h = "";
    for (var i = 0; i < value.length; i++) {
      f = value.codeUnitAt(i) ^ (nn / l * 255).floor();
      h += f < 16 ? ("0" + f.toRadixString(16)) : f.toRadixString(16);
      nn = (r * nn + c) % l;
    }
    var nd = d.toRadixString(16);
    for (; nd.length < 8;) {
      nd = "0" + nd;
    }
    return h + nd;
  }
}

