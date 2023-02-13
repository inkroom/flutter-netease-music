import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:kugou_api/ku_api.dart';
import 'package:kuwo_api/kuwo_api.dart';
import 'package:migu_api/migu_api.dart';
import 'package:netease_api/netease_api.dart' as netease_api;
import 'package:path/path.dart' as p;
import 'package:quiet/component/cache/cache.dart';
import 'package:quiet/providers/settings_provider.dart';
import 'package:quiet/repository.dart';
import 'package:quiet/repository/data/search_result.dart';

import './database.dart';
import '../component/exceptions.dart';

export 'package:netease_api/netease_api.dart'
    show
        SearchType,
        PlaylistOperation,
        CommentThreadId,
        CommentType,
        MusicCount,
        CellphoneExistenceCheck,
        PlayRecordType;

class NetworkRepository {
  NetworkRepository(this.cachePath)
      : _lyricCache = _LyricCache(p.join(cachePath));

  static Future<void> initialize() async {
    final cookiePath = await getCookieDirectory();

    /// 注册api
    MusicApiContainer.instance.regiester(KuApi(cookiePath));
    MusicApiContainer.instance.regiester(netease_api.Repository(cookiePath));
    MusicApiContainer.instance.regiester(KuWoApi(cookiePath));
    MusicApiContainer.instance.regiester(MiGuApi(cookiePath));

    networkRepository = NetworkRepository(await getLyricDirectory());
  }

  final String cachePath;

  final _LyricCache _lyricCache;

  /// 检查是否需要更新
  /// 需要更新返回新的版本号，否则返回null
  Future<dynamic> checkUpdate(bool github) {
    if (github) {
      return Dio()
          .get(
              "https://api.github.com/repos/inkroom/flutter-netease-music/releases/latest")
          .then((value) => value.data);
    }
    // 获取网络版本
    return Dio()
        .get("http://minio.bcyunqian.com/temp/quiet/version.json")
        .then((value) => value.data);
  }

  /// Fetch lyric by track id
  Future<String?> lyric(Track id) {
    final key = CacheKey.fromString(
        id.id.toString() + id.extra); // 如果修改歌词文件缓存位置，注意调整导出功能
    return _lyricCache.get(key).then((value) {
      if (value != null) {
        return Future.value(value.toString());
      }
      if (!NetworkSingleton().allowNetwork()) {
        return Future.error(NetworkException('网络设置不允许'));
      }
      return MusicApiContainer.instance
          .getApi(id.origin)
          .then((value) => value.lyric(id));
    }).then((value) {
      if (value == null) return Future.error(LyricException(''));
      _lyricCache.update(key, value);
      return value;
    });
  }

  Future<Result<List<String>>> searchHotWords() async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).searchHotWords());
  }

  ///search by keyword
  Future<Result<Map>> search(
    String? keyword,
    netease_api.SearchType type, {
    int limit = 20,
    int offset = 0,
  }) {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance.getApi(1).then((value) =>
        (value as netease_api.Repository)
            .searchByType(keyword, type, limit: limit, offset: offset));
  }

  Future<SearchResult<List<Track>>> searchMusics(String keyword,
      {int page = 1, int size = 20, int origin = 1}) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final ret = await MusicApiContainer.instance
        .getApi(origin)
        .then((value) => value.search(keyword, page, size));
    final result = ret;
    return (SearchResult<List<Track>>(
      result: result.data,
      hasMore: result.hasMore,
      totalCount: result.total,
    ));
  }

  Future<Result<List<String>>> searchSuggest(String? keyword) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance.getApi(1).then(
        (value) => (value as netease_api.Repository).searchSuggest(keyword));
  }

  ///edit playlist tracks
  ///true : succeed
  Future<bool> playlistTracksEdit(
    netease_api.PlaylistOperation operation,
    int playlistId,
    List<int?> musicIds,
  ) {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).playlistTracksEdit(
              operation,
              playlistId,
              musicIds,
            ));
  }

  Future<bool> playlistSubscribe(int? id, {required bool subscribe}) {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance.getApi(1).then((value) =>
        (value as netease_api.Repository)
            .playlistSubscribe(id, subscribe: subscribe));
  }

  Future<Result<Map>> getComments(
    netease_api.CommentThreadId commentThread, {
    int limit = 20,
    int offset = 0,
  }) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).getComments(
              commentThread,
              limit: limit,
              offset: offset,
            ));
  }

  // like track.
  Future<bool> like(int? musicId, {required bool like}) {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance.getApi(1).then(
        (value) => (value as netease_api.Repository).like(musicId, like: like));
  }

  // get user licked tracks.
  Future<Result<List<int>>> likedList(int? userId) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).likedList(userId));
  }

  Future<Result<netease_api.MusicCount>> subCount() async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).subCount());
  }

  Future<Result<netease_api.CellphoneExistenceCheck>> checkPhoneExist(
    String phone,
    String countryCode,
  ) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).checkPhoneExist(
              phone,
              countryCode,
            ));
  }

  Future<Result<List<PlaylistDetail>>> userPlaylist(
    int? userId, {
    int offset = 0,
    int limit = 1000,
  }) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final ret = await MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).userPlaylist(
              userId,
              offset: offset,
              limit: limit,
            ));
    if (ret.isError) {
      return ret.asError!;
    }
    final userPlayList = ret.asValue!.value;
    return Result.value(
      userPlayList.playlist.map((e) => e.toPlaylistDetail(const [])).toList(),
    );
  }

  Future<Result<PlaylistDetail>> playlistDetail(
    int id, {
    int s = 5,
  }) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final ret = await MusicApiContainer.instance.getApi(1).then(
        (value) => (value as netease_api.Repository).playlistDetail(id, s: s));
    if (ret.isError) {
      return ret.asError!;
    }
    final value = ret.asValue!.value;
    return Result.value(value.playlist.toPlaylistDetail(value.privileges));
  }

  Future<Result<AlbumDetail>> albumDetail(int id) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final ret = await MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).albumDetail(id));
    if (ret.isError) {
      return ret.asError!;
    }
    final albumDetail = ret.asValue!.value;
    return Result.value(AlbumDetail(
      album: albumDetail.album.toAlbum(),
      tracks: albumDetail.songs.map((e) => e.toTrack(null)).toList(),
    ));
  }

  Future<Result<netease_api.MusicVideoDetailResult>> mvDetail(int mvId) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).mvDetail(mvId));
  }

  Future<Result<ArtistDetail>> artistDetail(int id) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final ret = await MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).artistDetail(id));
    if (ret.isError) {
      return ret.asError!;
    }
    final artistDetail = ret.asValue!.value;
    return Result.value(ArtistDetail(
      artist: artistDetail.artist.toArtist(),
      hotSongs: artistDetail.hotSongs.map((e) => e.toTrack(null)).toList(),
      more: artistDetail.more,
    ));
  }

  // FIXME
  Future<Result<Map>> artistAlbums(int artistId,
      {int limit = 10, int offset = 0}) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).artistAlbums(
              artistId,
              limit: limit,
              offset: offset,
            ));
  }

  // FIXME
  Future<Result<Map>> artistMvs(int artistId,
      {int limit = 20, int offset = 0}) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).artistMvs(
              artistId,
              limit: limit,
              offset: offset,
            ));
  }

  // FIXME
  Future<Result<Map>> artistDesc(int artistId) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance.getApi(1).then(
        (value) => (value as netease_api.Repository).artistDesc(artistId));
  }

  // FIXME
  Future<Result<Map>> topListDetail() async => Result.error('not implement');

  Future<Result<List<PlayRecord>>> getRecord(
      int userId, netease_api.PlayRecordType type) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final records = await MusicApiContainer.instance.getApi(1).then(
        (value) => (value as netease_api.Repository).getRecord(userId, type));
    if (records.isError) {
      return records.asError!;
    }
    final record = records.asValue!.value;
    return Result.value(record
        .map((e) => PlayRecord(
              playCount: e.playCount,
              score: e.score,
              song: e.song.toTrack(null),
            ))
        .toList());
  }

  // FIXME
  Future<Result<List<Map>>> djSubList() async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).djSubList());
  }

  Future<Result<List<Map>>> userDj(int? userId) async =>
      Result.error('not implement');

  Future<Result<List<Track>>> personalizedNewSong() async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final ret = await MusicApiContainer.instance.getApi(1).then(
        (value) => (value as netease_api.Repository).personalizedNewSong());
    if (ret.isError) {
      return ret.asError!;
    }
    final personalizedNewSong = ret.asValue!.value.result;
    return Result.value(
      personalizedNewSong.map((e) => e.song.toTrack(e.song.privilege)).toList(),
    );
  }

  Future<Result<List<RecommendedPlaylist>>> personalizedPlaylist({
    int limit = 30,
    int offset = 0,
  }) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final ret = await MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).personalizedPlaylist(
              limit: limit,
              offset: offset,
            ));
    if (ret.isError) {
      return ret.asError!;
    }
    final personalizedPlaylist = ret.asValue!.value.result;
    return Result.value(
      personalizedPlaylist
          .map((e) => RecommendedPlaylist(
                id: e.id,
                name: e.name,
                copywriter: e.copywriter,
                picUrl: e.picUrl,
                playCount: e.playCount,
                trackCount: e.trackCount,
                alg: e.alg,
              ))
          .toList(),
    );
  }

  Future<Result<List<Track>>> songDetails(List<int> ids) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final ret = await MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).songDetails(ids));
    if (ret.isError) {
      return ret.asError!;
    }
    final songDetails = ret.asValue!.value.songs;
    return Result.value(
      songDetails.map((e) => e.toTrack(null)).toList(),
    );
  }

  Future<bool> mvSubscribe(int? mvId, {required bool subscribe}) {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance.getApi(1).then((value) =>
        (value as netease_api.Repository)
            .mvSubscribe(mvId, subscribe: subscribe));
  }

  Future<bool> refreshLogin() {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).refreshLogin());
  }

  Future<void> logout() {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).logout());
  }

  // FIXME
  Future<Result<Map>> login(String? phone, String password) {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance.getApi(1).then(
        (value) => (value as netease_api.Repository).login(phone, password));
  }

  Future<Result<User>> getUserDetail(int uid) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final ret = await MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).getUserDetail(uid));
    if (ret.isError) {
      return ret.asError!;
    }
    final userDetail = ret.asValue!.value;
    return Result.value(userDetail.toUser());
  }

  Future<Result<List<Track>>> recommendSongs() async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final ret = await MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).recommendSongs());
    if (ret.isError) {
      return ret.asError!;
    }
    final recommendSongs = ret.asValue!.value.dailySongs;
    return Result.value(
      recommendSongs.map((e) => e.toTrack(e.privilege)).toList(),
    );
  }

  Future<Track> getPlayUrl(Track track, [int br = 320000]) {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(track.origin)
        .then((value) => value.playUrl(track));
  }

  Future<Result<List<Track>>> getPersonalFmMusics() async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final ret = await MusicApiContainer.instance.getApi(1).then(
        (value) => (value as netease_api.Repository).getPersonalFmMusics());
    if (ret.isError) {
      return ret.asError!;
    }
    final personalFm = ret.asValue!.value.data;
    return Result.value(personalFm.map((e) => e.toTrack(e.privilege)).toList());
  }

  Future<CloudTracksDetail> getUserCloudTracks() async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final ret = await MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as netease_api.Repository).getUserCloudMusic());
    final value = await ret.asFuture;
    return CloudTracksDetail(
      maxSize: int.tryParse(value.maxSize) ?? 0,
      size: int.tryParse(value.size) ?? 0,
      trackCount: value.count,
      tracks: value.data.map((e) => e.toTrack()).toList(),
    );
  }
}

// https://github.com/Binaryify/NeteaseCloudMusicApi/issues/899#issuecomment-680002883
TrackType _trackType({
  required int fee,
  required bool cs,
  required int st,
}) {
  if (st == -200) {
    return TrackType.noCopyright;
  }
  if (cs) {
    return TrackType.cloud;
  }
  switch (fee) {
    case 0:
    case 8:
      return TrackType.free;
    case 4:
      return TrackType.payAlbum;
    case 1:
      return TrackType.vip;
  }
  debugPrint('unknown fee: $fee');
  return TrackType.free;
}

extension _CloudTrackMapper on netease_api.CloudSongItem {
  Track toTrack() {
    final album = AlbumMini(
      id: simpleSong.al.id,
      picUri: simpleSong.al.picUrl,
      name: simpleSong.al.name is String ? simpleSong.al.name : '',
    );
    ArtistMini mapArtist(netease_api.SimpleSongArtistItem item) {
      return ArtistMini(
        id: item.id,
        name: item.name is String ? item.name : '',
        imageUrl: '',
      );
    }

    return Track(
      id: songId,
      name: songName,
      album: album,
      duration: Duration(milliseconds: simpleSong.dt),
      type: _trackType(fee: simpleSong.fee, cs: true, st: simpleSong.st),
      artists: simpleSong.ar.map(mapArtist).toList(),
      uri: '',
      imageUrl: album.picUri,
      file: null,
      mp3Url: null,
      origin: 1,
    );
  }
}

extension _FmTrackMapper on netease_api.FmTrackItem {
  Track toTrack(netease_api.Privilege privilege) => Track(
        id: id,
        name: name,
        artists: artists.map((e) => e.toArtist()).toList(),
        album: album.toAlbum(),
        imageUrl: album.picUrl,
        uri: 'http://music.163.com/song/media/outer/url?id=$id.mp3',
        duration: Duration(milliseconds: duration),
        type:
            _trackType(fee: privilege.fee, st: privilege.st, cs: privilege.cs),
        file: null,
        mp3Url: null,
        origin: 1,
      );
}

extension _FmArtistMapper on netease_api.FmArtist {
  ArtistMini toArtist() => ArtistMini(
        id: id,
        name: name,
        imageUrl: picUrl,
      );
}

extension _FmAlbumMapper on netease_api.FmAlbum {
  AlbumMini toAlbum() => AlbumMini(
        id: id,
        name: name,
        picUri: picUrl,
      );
}

extension _PlayListMapper on netease_api.Playlist {
  PlaylistDetail toPlaylistDetail(List<netease_api.PrivilegesItem> privileges) {
    assert(coverImgUrl.isNotEmpty, 'coverImgUrl is empty');
    final privilegesMap = Map<int, netease_api.PrivilegesItem>.fromEntries(
      privileges.map((e) => MapEntry(e.id, e)),
    );
    return PlaylistDetail(
      id: id,
      name: name,
      coverUrl: coverImgUrl,
      trackCount: trackCount,
      playCount: playCount,
      subscribedCount: subscribedCount,
      creator: creator.toUser(),
      description: description,
      subscribed: subscribed,
      tracks: tracks.map((e) => e.toTrack(privilegesMap[e.id])).toList(),
      commentCount: commentCount,
      shareCount: shareCount,
      trackUpdateTime: trackUpdateTime,
      trackIds: trackIds.map((e) => e.id).toList(),
      createTime: DateTime.fromMillisecondsSinceEpoch(createTime),
    );
  }
}

extension _TrackMapper on netease_api.TracksItem {
  Track toTrack(netease_api.PrivilegesItem? privilege) {
    final p = privilege ?? this.privilege;
    return Track(
      id: id,
      name: name,
      artists: ar.map((e) => e.toArtist()).toList(),
      album: al.toAlbum(),
      imageUrl: al.picUrl,
      uri: 'http://music.163.com/song/media/outer/url?id=$id.mp3',
      duration: Duration(milliseconds: dt),
      type: _trackType(
        fee: p?.fee ?? fee,
        cs: p?.cs ?? false,
        st: p?.st ?? st,
      ),
      file: null,
      mp3Url: null,
      origin: 1,

      ///默认为网易云的
    );
  }
}

extension _ArtistItemMapper on netease_api.ArtistItem {
  ArtistMini toArtist() {
    return ArtistMini(
      id: id,
      name: name,
      imageUrl: null,
    );
  }
}

extension _ArtistMapper on netease_api.Artist {
  Artist toArtist() {
    return Artist(
      id: id,
      name: name,
      picUrl: picUrl,
      briefDesc: briefDesc,
      mvSize: mvSize,
      albumSize: albumSize,
      followed: followed,
      musicSize: musicSize,
      publishTime: publishTime,
      image1v1Url: img1v1Url,
      alias: alias,
    );
  }
}

extension _AlbumItemMapper on netease_api.AlbumItem {
  AlbumMini toAlbum() {
    return AlbumMini(
      id: id,
      name: name,
      picUri: picUrl,
    );
  }
}

extension _AlbumMapper on netease_api.Album {
  Album toAlbum() {
    return Album(
      id: id,
      name: name,
      description: description,
      briefDesc: briefDesc,
      publishTime: DateTime.fromMillisecondsSinceEpoch(publishTime),
      paid: paid,
      artist: ArtistMini(
        id: artist.id,
        name: artist.name,
        imageUrl: artist.picUrl,
      ),
      shareCount: info.shareCount,
      commentCount: info.commentCount,
      likedCount: info.likedCount,
      liked: info.liked,
      onSale: onSale,
      company: company,
      picUrl: picUrl,
      size: size,
    );
  }
}

extension _UserMapper on netease_api.Creator {
  User toUser() {
    return User(
      userId: userId,
      nickname: nickname,
      avatarUrl: avatarUrl,
      followers: 0,
      followed: followed,
      backgroundUrl: backgroundUrl,
      createTime: 0,
      description: description,
      detailDescription: detailDescription,
      playlistBeSubscribedCount: 0,
      playlistCount: 0,
      allSubscribedCount: 0,
      followedUsers: 0,
      vipType: vipType,
      level: 0,
      eventCount: 0,
    );
  }
}

extension _UserDetailMapper on netease_api.UserDetail {
  User toUser() {
    return User(
      userId: profile.userId,
      nickname: profile.nickname,
      avatarUrl: profile.avatarUrl,
      followers: profile.follows,
      followed: profile.followed,
      backgroundUrl: profile.backgroundUrl,
      createTime: createTime,
      description: profile.description,
      detailDescription: profile.detailDescription,
      playlistBeSubscribedCount: profile.playlistBeSubscribedCount,
      playlistCount: profile.playlistCount,
      allSubscribedCount: profile.allSubscribedCount,
      followedUsers: profile.followeds,
      vipType: profile.vipType,
      level: level,
      eventCount: profile.eventCount,
    );
  }
}

class _LyricCache implements Cache<String?> {
  _LyricCache(String dir)
      : provider =
            FileCacheProvider(dir, maxSize: 20 * 1024 * 1024 /* 20 Mb */);

  final FileCacheProvider provider;

  @override
  Future<String?> get(CacheKey key) async {
    final file = provider.getFile(key);
    if (await file.exists()) {
      provider.touchFile(file);
      return file.readAsStringSync();
    }
    return null;
  }

  @override
  Future<bool> update(CacheKey key, String? t) async {
    if (t == null) return Future.value(false);
    var file = provider.getFile(key);

    if (file.existsSync()) {
      file.deleteSync();
    }

    file.createSync(recursive: true);
    file.writeAsStringSync(t);
    try {
      return file.exists();
    } finally {
      provider.checkSize();
    }
  }
}
