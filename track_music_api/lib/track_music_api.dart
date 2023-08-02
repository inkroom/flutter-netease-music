import 'dart:convert';

import 'package:quiet/component/utils/time.dart';

import 'src/track.dart';

export 'src/track.dart';

/// 歌词处理
///

class LyricContent {
  LyricContent.from(String text) {
    final List<String> lines = _kLineSplitter.convert(text);
    _lines.addAll(lines);
    final Map map = <int, String>{};
    for (final line in lines) {
      LyricEntry.inflate(line, map as Map<int, String>);
    }

    final List<int> keys = map.keys.toList() as List<int>..sort();
    for (var i = 0; i < keys.length; i++) {
      final key = keys[i];
      _durations.add(key);
      int duration = _kDefaultLineDuration;
      if (i + 1 < keys.length) {
        duration = keys[i + 1] - key;
      }
      _lyricEntries.add(LyricEntry(map[key], key, duration));
    }
  }

  ///splitter lyric content to line
  static const LineSplitter _kLineSplitter = LineSplitter();

  //默认歌词持续时间
  static const int _kDefaultLineDuration = 5 * 1000;

  final List<int> _durations = [];
  final List<LyricEntry> _lyricEntries = [];
  final List<String> _lines = [];

  int get size => _durations.length;

  LyricEntry operator [](int index) {
    return _lyricEntries[index];
  }

  int _getTimeStamp(int index) {
    return _durations[index];
  }

  LyricEntry? getLineByTimeStamp(final int timeStamp, final int anchorLine) {
    if (size <= 0) {
      return null;
    }
    final line = findLineByTimeStamp(timeStamp, anchorLine);
    return this[line];
  }

  ///
  /// 拼接另一份歌词
  LyricContent contact(LyricContent other) {
    final List<int> durations = [];
    final List<LyricEntry> lyricEntries = [];
    final List<String> line = [];
    var i1 = 0;
    var i2 = 0;
    while (i1 < _durations.length && i2 < other._durations.length) {
      if (_durations[i1] == other._durations[i2]) {
        durations.add(_durations[i1]);
        if (_lyricEntries[i1].line != null &&
            other._lyricEntries[i2].line != null &&
            _lyricEntries[i1].line! != other._lyricEntries[i2].line) {
          line.add(_lines[i1] + "  " + other._lyricEntries[i2].line!);
          lyricEntries.add(LyricEntry(
              _lyricEntries[i1].line! + "  " + other._lyricEntries[i2].line!,
              _lyricEntries[i1].position,
              _lyricEntries[i1].duration));
        } else {
          lyricEntries.add(_lyricEntries[i1]);
          line.add(_lines[i1]);
        }
        i1++;
        i2++;
      } else if (_durations[i1] < other._durations[i2]) {
        durations.add(_durations[i1]);
        lyricEntries.add(_lyricEntries[i1]);
        line.add(_lines[i1]);
        i1++;
      } else {
        durations.add(_durations[i2]);
        lyricEntries.add(_lyricEntries[i2]);
        line.add(_lines[i2]);
        i2++;
      }
    }
    if (i1 < _durations.length) {
      durations.addAll(_durations.sublist(i1, _durations.length - 1));
      lyricEntries.addAll(_lyricEntries.sublist(i1, _lyricEntries.length - 1));
      line.addAll(_lines.sublist(i1));
    } else if (i2 < other._durations.length) {
      durations
          .addAll(other._durations.sublist(i2, other._durations.length - 1));
      lyricEntries.addAll(
          other._lyricEntries.sublist(i2, other._lyricEntries.length - 1));
      line.addAll(_lines.sublist(i2));
    }
    _durations.clear();
    _durations.addAll(durations);
    _lyricEntries.clear();
    _lyricEntries.addAll(lyricEntries);
    _lines.clear();
    _lines.addAll(line);
    return this;
  }

  ///
  ///根据时间戳来寻找匹配当前时刻的歌词
  ///
  ///@param timeStamp  歌词的时间戳(毫秒)
  ///@param anchorLine the start line to search
  ///@return index to getLyricEntry
  ///
  int findLineByTimeStamp(final int timeStamp, final int anchorLine) {
    int position = anchorLine;
    if (position < 0 || position > size - 1) {
      position = 0;
    }
    if (_getTimeStamp(position) > timeStamp) {
      // look forward
      // ignore: invariant_booleans
      while (_getTimeStamp(position) > timeStamp) {
        position--;
        if (position <= 0) {
          position = 0;
          break;
        }
      }
    } else {
      while (_getTimeStamp(position) < timeStamp) {
        position++;
        if (position <= size - 1 && _getTimeStamp(position) > timeStamp) {
          position--;
          break;
        }
        if (position >= size - 1) {
          position = size - 1;
          break;
        }
      }
    }
    return position;
  }

  @override
  String toString() {
    return _lines.join("\n");
  }
}

class LyricEntry {
  LyricEntry(this.line, this.position, this.duration)
      : timeStamp = getTimeStamp(position);

  static RegExp pattern = RegExp(r"\[\d{2}:\d{2}.\d{2,3}]");

  static int _stamp2int(final String stamp) {
    final int indexOfColon = stamp.indexOf(":");
    final int indexOfPoint = stamp.indexOf(".");

    final int minute = int.parse(stamp.substring(1, indexOfColon));
    final int second =
        int.parse(stamp.substring(indexOfColon + 1, indexOfPoint));
    int millisecond;
    if (stamp.length - indexOfPoint == 2) {
      millisecond =
          int.parse(stamp.substring(indexOfPoint + 1, stamp.length)) * 10;
    } else {
      millisecond =
          int.parse(stamp.substring(indexOfPoint + 1, stamp.length - 1));
    }
    return (((minute * 60) + second) * 1000) + millisecond;
  }

  ///build from a .lrc file line .such as: [11:44.100] what makes your beautiful
  static void inflate(String line, Map<int, String> map) {
    //TODO lyric info
    if (line.startsWith("[ti:")) {
    } else if (line.startsWith("[ar:")) {
    } else if (line.startsWith("[al:")) {
    } else if (line.startsWith("[au:")) {
    } else if (line.startsWith("[by:")) {
    } else {
      final stamps = pattern.allMatches(line);
      final content = line.split(pattern).last;
      for (final stamp in stamps) {
        final int timeStamp = _stamp2int(stamp.group(0)!);
        map[timeStamp] = content;
      }
    }
  }

  final String timeStamp;
  final String? line;

  final int position;

  ///the duration of this line
  final int duration;

  @override
  String toString() {
    return 'LyricEntry{line: $line, timeStamp: $timeStamp}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricEntry &&
          runtimeType == other.runtimeType &&
          line == other.line &&
          timeStamp == other.timeStamp;

  @override
  int get hashCode => line.hashCode ^ timeStamp.hashCode;
}

/// 基础接口

class PageResult<T> {
  PageResult({required this.data, this.total = 0, this.hasMore = false});

  List<T> data;

  ///总记录数
  int total;

  /// 是否还有下一页
  bool hasMore;
}

abstract class MusicApi {
  //  只需要实现几个简单的接口即可，

  /// [keyword] 关键字
  /// [page] 页码，从1开始
  /// [size] 每页记录数
  ///
  Future<PageResult<Track>> search(String keyword, int page, int size);

  /// 获取音乐播放url的接口
  Future<Track> playUrl(Track track);

  /// 获取歌词
  Future<LyricContent?> lyric(Track track);

  /// 获取唯一标志
  int get origin;

  /// 获取源name
  String get name;

  /// 获取包名，用于获取icon
  String get package;

//// icon 位置
  String get icon;
}

/// 负责管理api
class MusicApiContainer {
  MusicApiContainer._internal();

  factory MusicApiContainer() => _getInstance();

  static MusicApiContainer get instance => _getInstance();
  static MusicApiContainer _instance = MusicApiContainer._internal();

  static MusicApiContainer _getInstance() {
    return _instance;
  }

  final List<MusicApi> _plugins = List.empty(growable: true);

  /// 注册
  regiester(MusicApi api) {
    for (var s in _plugins) {
      if (s.origin == api.origin) {
        throw RegisterException('$api 注册失败');
      }
    }

    if (_plugins.contains(api)) {
      return;
    }
    _plugins.add(api);
  }

  Future<MusicApi> getApi(int origin) {
    for (var s in _plugins) {
      if (s.origin == origin) return Future.value(s);
    }
    return Future.error(UnsupportedOriginException);
  }

  MusicApi? getApiSync(int origin) {
    for (var s in _plugins) {
      if (s.origin == origin) return s;
    }
    return null;
  }

  List<MusicApi> get list => _plugins;
}

/// 定义一些错误异常来使用
///
///
///

class MusicException implements Exception {
  const MusicException(this.message, [this.track]);

  final String message;

  final Track? track;

  @override
  String toString() =>
      'MusicException: $message ' + (track == null ? "" : track!.toString());
}

class UnsupportedOriginException extends MusicException {
  UnsupportedOriginException(String message) : super(message);
}

class RegisterException extends MusicException {
  RegisterException(String message) : super(message);
}

class PlayDetailException extends MusicException {
  PlayDetailException(String message, [Track? track]) : super(message, track);
}

class SearchException extends MusicException {
  SearchException(String message) : super(message);
}

/// 部分api可能不支持某项功能
class UnsupportedException extends MusicException {
  UnsupportedException(String message) : super(message);
}

class LyricException extends MusicException {
  LyricException(String message, [Track? track]) : super(message, track);
}
