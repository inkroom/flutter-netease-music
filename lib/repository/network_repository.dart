import 'dart:developer';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:kugou_api/ku_api.dart';
import 'package:kuwo_api/kuwo_api.dart';
import 'package:netease_api/netease_api.dart' as neteaseApi;
import 'package:path/path.dart' as p;
import 'package:quiet/component/cache/cache.dart';
import 'package:quiet/providers/settings_provider.dart';
import 'package:quiet/repository.dart';
import 'package:quiet/repository/data/search_result.dart';

import '../component/exceptions.dart';

import './database.dart';

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
    MusicApiContainer.instance.regiester(neteaseApi.Repository(cookiePath));
    MusicApiContainer.instance.regiester(KuWoApi(cookiePath));

    networkRepository = NetworkRepository(await getLyricDirectory());
  }

  final String cachePath;

  final _LyricCache _lyricCache;

  /// Fetch lyric by track id
  Future<String?> lyric(Track id) {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final key = CacheKey.fromString(id.id.toString() + id.extra);
    return _lyricCache.get(key).then((value) {
      if (value != null) {
        return Future.value(value.toString());
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
        .then((value) => (value as neteaseApi.Repository).searchHotWords());
  }

  ///search by keyword
  Future<Result<Map>> search(
    String? keyword,
    neteaseApi.SearchType type, {
    int limit = 20,
    int offset = 0,
  }) {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance.getApi(1).then((value) =>
        (value as neteaseApi.Repository)
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
        (value) => (value as neteaseApi.Repository).searchSuggest(keyword));
  }

  ///edit playlist tracks
  ///true : succeed
  Future<bool> playlistTracksEdit(
    neteaseApi.PlaylistOperation operation,
    int playlistId,
    List<int?> musicIds,
  ) {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as neteaseApi.Repository).playlistTracksEdit(
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
        (value as neteaseApi.Repository)
            .playlistSubscribe(id, subscribe: subscribe));
  }

  Future<Result<Map>> getComments(
    neteaseApi.CommentThreadId commentThread, {
    int limit = 20,
    int offset = 0,
  }) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as neteaseApi.Repository).getComments(
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
        (value) => (value as neteaseApi.Repository).like(musicId, like: like));
  }

  // get user licked tracks.
  Future<Result<List<int>>> likedList(int? userId) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as neteaseApi.Repository).likedList(userId));
  }

  Future<Result<neteaseApi.MusicCount>> subCount() async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as neteaseApi.Repository).subCount());
  }

  Future<Result<neteaseApi.CellphoneExistenceCheck>> checkPhoneExist(
    String phone,
    String countryCode,
  ) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as neteaseApi.Repository).checkPhoneExist(
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
        .then((value) => (value as neteaseApi.Repository).userPlaylist(
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
        (value) => (value as neteaseApi.Repository).playlistDetail(id, s: s));
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
        .then((value) => (value as neteaseApi.Repository).albumDetail(id));
    if (ret.isError) {
      return ret.asError!;
    }
    final albumDetail = ret.asValue!.value;
    return Result.value(AlbumDetail(
      album: albumDetail.album.toAlbum(),
      tracks: albumDetail.songs.map((e) => e.toTrack(null)).toList(),
    ));
  }

  Future<Result<neteaseApi.MusicVideoDetailResult>> mvDetail(int mvId) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as neteaseApi.Repository).mvDetail(mvId));
  }

  Future<Result<ArtistDetail>> artistDetail(int id) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final ret = await MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as neteaseApi.Repository).artistDetail(id));
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
        .then((value) => (value as neteaseApi.Repository).artistAlbums(
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
        .then((value) => (value as neteaseApi.Repository).artistMvs(
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
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as neteaseApi.Repository).artistDesc(artistId));
  }

  // FIXME
  Future<Result<Map>> topListDetail() async => Result.error('not implement');

  Future<Result<List<PlayRecord>>> getRecord(
      int userId, neteaseApi.PlayRecordType type) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final records = await MusicApiContainer.instance.getApi(1).then(
        (value) => (value as neteaseApi.Repository).getRecord(userId, type));
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
        .then((value) => (value as neteaseApi.Repository).djSubList());
  }

  Future<Result<List<Map>>> userDj(int? userId) async =>
      Result.error('not implement');

  Future<Result<List<Track>>> personalizedNewSong() async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final ret = await MusicApiContainer.instance.getApi(1).then(
        (value) => (value as neteaseApi.Repository).personalizedNewSong());
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
        .then((value) => (value as neteaseApi.Repository).personalizedPlaylist(
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
        .then((value) => (value as neteaseApi.Repository).songDetails(ids));
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
        (value as neteaseApi.Repository)
            .mvSubscribe(mvId, subscribe: subscribe));
  }

  Future<bool> refreshLogin() {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as neteaseApi.Repository).refreshLogin());
  }

  Future<void> logout() {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as neteaseApi.Repository).logout());
  }

  // FIXME
  Future<Result<Map>> login(String? phone, String password) {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    return MusicApiContainer.instance.getApi(1).then(
        (value) => (value as neteaseApi.Repository).login(phone, password));
  }

  Future<Result<User>> getUserDetail(int uid) async {
    if (!NetworkSingleton().allowNetwork()) {
      return Future.error(NetworkException('网络设置不允许'));
    }
    final ret = await MusicApiContainer.instance
        .getApi(1)
        .then((value) => (value as neteaseApi.Repository).getUserDetail(uid));
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
        .then((value) => (value as neteaseApi.Repository).recommendSongs());
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
        (value) => (value as neteaseApi.Repository).getPersonalFmMusics());
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
        .then((value) => (value as neteaseApi.Repository).getUserCloudMusic());
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

extension _CloudTrackMapper on neteaseApi.CloudSongItem {
  Track toTrack() {
    final album = AlbumMini(
      id: simpleSong.al.id,
      picUri: simpleSong.al.picUrl,
      name: simpleSong.al.name is String ? simpleSong.al.name : '',
    );
    ArtistMini mapArtist(neteaseApi.SimpleSongArtistItem item) {
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

extension _FmTrackMapper on neteaseApi.FmTrackItem {
  Track toTrack(neteaseApi.Privilege privilege) => Track(
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

extension _FmArtistMapper on neteaseApi.FmArtist {
  ArtistMini toArtist() => ArtistMini(
        id: id,
        name: name,
        imageUrl: picUrl,
      );
}

extension _FmAlbumMapper on neteaseApi.FmAlbum {
  AlbumMini toAlbum() => AlbumMini(
        id: id,
        name: name,
        picUri: picUrl,
      );
}

extension _PlayListMapper on neteaseApi.Playlist {
  PlaylistDetail toPlaylistDetail(List<neteaseApi.PrivilegesItem> privileges) {
    assert(coverImgUrl.isNotEmpty, 'coverImgUrl is empty');
    final privilegesMap = Map<int, neteaseApi.PrivilegesItem>.fromEntries(
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

extension _TrackMapper on neteaseApi.TracksItem {
  Track toTrack(neteaseApi.PrivilegesItem? privilege) {
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
      origin: 1,///默认为网易云的
    );
  }
}

extension _ArtistItemMapper on neteaseApi.ArtistItem {
  ArtistMini toArtist() {
    return ArtistMini(
      id: id,
      name: name,
      imageUrl: null,
    );
  }
}

extension _ArtistMapper on neteaseApi.Artist {
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

extension _AlbumItemMapper on neteaseApi.AlbumItem {
  AlbumMini toAlbum() {
    return AlbumMini(
      id: id,
      name: name,
      picUri: picUrl,
    );
  }
}

extension _AlbumMapper on neteaseApi.Album {
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

extension _UserMapper on neteaseApi.Creator {
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

extension _UserDetailMapper on neteaseApi.UserDetail {
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
