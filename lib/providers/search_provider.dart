import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/repository.dart';
import 'package:quiet/repository/data/search_result.dart';

final searchMusicProvider = StateNotifierProvider.family<
    SearchResultStateNotify<Track>, SearchResultState<Track>, String>(
  (ref, query) => _TrackResultStateNotify(query),
);

/// 参数随便填，但是如果要监听的话，确保前后传递的参数一致,获取数据要调用Notify
final mobileSearchMusicProvider = StateNotifierProvider.family<
    _MobileSearchNotify,
    SearchResultState<Track>,
    String>((ref, query) => _MobileSearchNotify());

/// 给移动端使用的搜索功能
class _MobileSearchNotify extends SearchResultStateNotify<Track> {
  _MobileSearchNotify() : super();

  @override
  int get pageSize => 100;

  void search(query) {
    super.query = query;
    super._loadQuery(1);
  }

  @override
  Future<SearchResult<List<Track>>> load(int page, int size) =>
      networkRepository!
          .searchMusics(query, page: page, size: size, origin: _origin);
}

class SearchResultState<T> with EquatableMixin {
  SearchResultState({
    required this.value,
    required this.query,
    required this.page,
    required this.totalPageCount,
    required this.totalItemCount,
    this.origin = 1,
  });

  final AsyncValue<List<T>> value;
  final String query;
  final int page;
  final int totalPageCount;
  final int totalItemCount;
  int origin;

  @override
  List<Object?> get props => [value, query, totalPageCount, totalItemCount];
}

abstract class SearchResultStateNotify<T>
    extends StateNotifier<SearchResultState<T>> {
  SearchResultStateNotify()
      : super(SearchResultState<T>(
            value: AsyncValue.data(List.empty()),
            page: 1,
            totalPageCount: 0,
            totalItemCount: 0,
            query: ''));

  int get pageSize;

  bool _loading = false;

  int? _totalItemCount;
  int _page = 1;

  int _origin = 1;

  String query = '';

  set origin(int origin) {
    if (_origin != origin) {
      //切换来源，自动搜索
      _origin = origin;
      notifyListener(const AsyncValue.data([]));
      _loadQuery(_page);
    } else {
      _origin = origin;
      notifyListener(const AsyncValue.data([]));
    }
  }

  void _loadQuery(int page) async {
    log('查询=$query');
    if (query.isEmpty) return;
    if (_loading) {
      return;
    }
    _loading = true;
    _page = page;
    notifyListener(const AsyncValue.loading());
    try {
      final result = await load(page, pageSize);
      _totalItemCount = result.totalCount;
      notifyListener(AsyncValue.data(result.result));
    } catch (error, stacktrace) {
      log('歌曲搜索 error $error');
      notifyListener(AsyncValue.error(error, stackTrace: stacktrace));
    } finally {
      _loading = false;
    }
  }

  Future<SearchResult<List<T>>> load(int page, int size);

  void notifyListener(AsyncValue<List<T>> value) {
    state = SearchResultState<T>(
      value: value,
      query: query,
      totalPageCount:
          _totalItemCount == null ? -1 : (_totalItemCount! / pageSize).round(),
      totalItemCount: _totalItemCount ?? -1,
      page: _page,
      origin: _origin,
    );
  }
}

class _TrackResultStateNotify extends SearchResultStateNotify<Track> {
  _TrackResultStateNotify(String query) : super() {
    super.query = query;
    _loadQuery(1);
  }

  @override
  Future<SearchResult<List<Track>>> load(int page, int size) =>
      networkRepository!
          .searchMusics(query, page: page, size: size, origin: _origin);

  @override
  int get pageSize => 100;
}
