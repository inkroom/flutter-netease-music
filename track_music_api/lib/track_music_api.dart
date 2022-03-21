export 'src/track.dart';

import 'src/track.dart';

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

  /// 获取唯一标志
  int get origin;
  /// 获取源name
  String get name;
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
        throw Exception('$api 注册失败');
      }
    }

    if (_plugins.contains(api)) {
      return;
    }
    _plugins.add(api);
  }

  MusicApi? getApi(int origin) {
    for (var s in _plugins) {
      if (s.origin == origin) return s;
    }
    return null;
  }

  List<MusicApi> get list => _plugins;
}
