// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Close`
  String get alterActionClose {
    return Intl.message(
      'Close',
      name: 'alterActionClose',
      desc: '',
      args: [],
    );
  }

  /// `App Has Launched`
  String get alertAppLaunched {
    return Intl.message(
      'App Has Launched',
      name: 'alertAppLaunched',
      desc: '',
      args: [],
    );
  }

  /// `Show`
  String get trayItemShow {
    return Intl.message(
      'Show',
      name: 'trayItemShow',
      desc: '',
      args: [],
    );
  }

  /// `Hide`
  String get trayItemHide {
    return Intl.message(
      'Hide',
      name: 'trayItemHide',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get trayItemExit {
    return Intl.message(
      'Exit',
      name: 'trayItemExit',
      desc: '',
      args: [],
    );
  }

  /// `The File Save Path`
  String get savePath {
    return Intl.message(
      'The File Save Path',
      name: 'savePath',
      desc: '',
      args: [],
    );
  }

  /// `Unsupported Origin`
  String get unsupportedOrigin {
    return Intl.message(
      'Unsupported Origin',
      name: 'unsupportedOrigin',
      desc: '',
      args: [],
    );
  }

  /// `Newest Version`
  String get newestVersion {
    return Intl.message(
      'Newest Version',
      name: 'newestVersion',
      desc: '',
      args: [],
    );
  }

  /// `Check Update`
  String get checkUpdate {
    return Intl.message(
      'Check Update',
      name: 'checkUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Remove {name} From Music List ?`
  String deleteTrackConfirm(Object name) {
    return Intl.message(
      'Remove $name From Music List ?',
      name: 'deleteTrackConfirm',
      desc: '',
      args: [name],
    );
  }

  /// `Only For Special Person`
  String get applicationLegalese {
    return Intl.message(
      'Only For Special Person',
      name: 'applicationLegalese',
      desc: '',
      args: [],
    );
  }

  /// `{appName} is updating`
  String updateTitle(Object appName) {
    return Intl.message(
      '$appName is updating',
      name: 'updateTitle',
      desc: '',
      args: [appName],
    );
  }

  /// `New Version {version}, Updating`
  String updateTip(Object version) {
    return Intl.message(
      'New Version $version, Updating',
      name: 'updateTip',
      desc: '',
      args: [version],
    );
  }

  /// `Album: {count}`
  String albumCount(Object count) {
    return Intl.message(
      'Album: $count',
      name: 'albumCount',
      desc: '',
      args: [count],
    );
  }

  /// `Video : {count}`
  String videoCount(Object count) {
    return Intl.message(
      'Video : $count',
      name: 'videoCount',
      desc: '',
      args: [count],
    );
  }

  /// `Artist`
  String get artistInfo {
    return Intl.message(
      'Artist',
      name: 'artistInfo',
      desc: '',
      args: [],
    );
  }

  /// `Hot Song`
  String get hotSong {
    return Intl.message(
      'Hot Song',
      name: 'hotSong',
      desc: '',
      args: [],
    );
  }

  /// `The Music List Is Empty`
  String get emptyList {
    return Intl.message(
      'The Music List Is Empty',
      name: 'emptyList',
      desc: '',
      args: [],
    );
  }

  /// `Fetch Music Failed`
  String get getPlayDetailFail {
    return Intl.message(
      'Fetch Music Failed',
      name: 'getPlayDetailFail',
      desc: '',
      args: [],
    );
  }

  /// `Network`
  String get settingItemGroupNetwork {
    return Intl.message(
      'Network',
      name: 'settingItemGroupNetwork',
      desc: '',
      args: [],
    );
  }

  /// `Only WIFI`
  String get settingItemOnlyWIFI {
    return Intl.message(
      'Only WIFI',
      name: 'settingItemOnlyWIFI',
      desc: '',
      args: [],
    );
  }

  /// `Use 3/4/5G`
  String get settingItemOnlyMobile {
    return Intl.message(
      'Use 3/4/5G',
      name: 'settingItemOnlyMobile',
      desc: '',
      args: [],
    );
  }

  /// `No Network`
  String get settingItemNoNetwork {
    return Intl.message(
      'No Network',
      name: 'settingItemNoNetwork',
      desc: '',
      args: [],
    );
  }

  /// `The Network Setting Not Allow`
  String get networkNotAllow {
    return Intl.message(
      'The Network Setting Not Allow',
      name: 'networkNotAllow',
      desc: '',
      args: [],
    );
  }

  /// `Add To Music List`
  String get addToMusicList {
    return Intl.message(
      'Add To Music List',
      name: 'addToMusicList',
      desc: '',
      args: [],
    );
  }

  /// `Remove From Music List`
  String get removeFromMusicList {
    return Intl.message(
      'Remove From Music List',
      name: 'removeFromMusicList',
      desc: '',
      args: [],
    );
  }

  /// `Download Music`
  String get downloadMusic {
    return Intl.message(
      'Download Music',
      name: 'downloadMusic',
      desc: '',
      args: [],
    );
  }

  /// `My`
  String get my {
    return Intl.message(
      'My',
      name: 'my',
      desc: '',
      args: [],
    );
  }

  /// `Discover`
  String get discover {
    return Intl.message(
      'Discover',
      name: 'discover',
      desc: '',
      args: [],
    );
  }

  /// `Local Music`
  String get localMusic {
    return Intl.message(
      'Local Music',
      name: 'localMusic',
      desc: '',
      args: [],
    );
  }

  /// `Music List`
  String get cloudMusic {
    return Intl.message(
      'Music List',
      name: 'cloudMusic',
      desc: '',
      args: [],
    );
  }

  /// `Play History`
  String get latestPlayHistory {
    return Intl.message(
      'Play History',
      name: 'latestPlayHistory',
      desc: '',
      args: [],
    );
  }

  /// `Friends`
  String get friends {
    return Intl.message(
      'Friends',
      name: 'friends',
      desc: '',
      args: [],
    );
  }

  /// `Dj`
  String get myDjs {
    return Intl.message(
      'Dj',
      name: 'myDjs',
      desc: '',
      args: [],
    );
  }

  /// `Collections`
  String get collectionLike {
    return Intl.message(
      'Collections',
      name: 'collectionLike',
      desc: '',
      args: [],
    );
  }

  /// `Payed`
  String get alreadyBuy {
    return Intl.message(
      'Payed',
      name: 'alreadyBuy',
      desc: '',
      args: [],
    );
  }

  /// `TBD`
  String get todo {
    return Intl.message(
      'TBD',
      name: 'todo',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Login First`
  String get needLogin {
    return Intl.message(
      'Login First',
      name: 'needLogin',
      desc: '',
      args: [],
    );
  }

  /// `To Login Page`
  String get toLoginPage {
    return Intl.message(
      'To Login Page',
      name: 'toLoginPage',
      desc: '',
      args: [],
    );
  }

  /// `Login to discover your playlists.`
  String get playlistLoginDescription {
    return Intl.message(
      'Login to discover your playlists.',
      name: 'playlistLoginDescription',
      desc: '',
      args: [],
    );
  }

  /// `Created Song List`
  String get createdSongList {
    return Intl.message(
      'Created Song List',
      name: 'createdSongList',
      desc: '',
      args: [],
    );
  }

  /// `Favorite Song List`
  String get favoriteSongList {
    return Intl.message(
      'Favorite Song List',
      name: 'favoriteSongList',
      desc: '',
      args: [],
    );
  }

  /// `The PlayList created by {username}「{title}」: http://music.163.com/playlist/{playlistId}/{userId}/?userid={shareUserId} (From @NeteaseCouldMusic)`
  String playlistShareContent(Object username, Object title, Object playlistId,
      Object userId, Object shareUserId) {
    return Intl.message(
      'The PlayList created by $username「$title」: http://music.163.com/playlist/$playlistId/$userId/?userid=$shareUserId (From @NeteaseCouldMusic)',
      name: 'playlistShareContent',
      desc: '',
      args: [username, title, playlistId, userId, shareUserId],
    );
  }

  /// `Share content has copied to clipboard.`
  String get shareContentCopied {
    return Intl.message(
      'Share content has copied to clipboard.',
      name: 'shareContentCopied',
      desc: '',
      args: [],
    );
  }

  /// `The {artistName}'s album《{albumName}》: http://music.163.com/album/{albumId}/?userid={sharedUserId} (From @NeteaseCouldMusic)`
  String albumShareContent(Object artistName, Object albumName, Object albumId,
      Object sharedUserId) {
    return Intl.message(
      'The $artistName\'s album《$albumName》: http://music.163.com/album/$albumId/?userid=$sharedUserId (From @NeteaseCouldMusic)',
      name: 'albumShareContent',
      desc: '',
      args: [artistName, albumName, albumId, sharedUserId],
    );
  }

  /// `error to fetch data.`
  String get errorToFetchData {
    return Intl.message(
      'error to fetch data.',
      name: 'errorToFetchData',
      desc: '',
      args: [],
    );
  }

  /// `select region code`
  String get selectRegionDiaCode {
    return Intl.message(
      'select region code',
      name: 'selectRegionDiaCode',
      desc: '',
      args: [],
    );
  }

  /// `next step`
  String get nextStep {
    return Intl.message(
      'next step',
      name: 'nextStep',
      desc: '',
      args: [],
    );
  }

  /// `auto register if phone not exist`
  String get tipsAutoRegisterIfUserNotExist {
    return Intl.message(
      'auto register if phone not exist',
      name: 'tipsAutoRegisterIfUserNotExist',
      desc: '',
      args: [],
    );
  }

  /// `login with phone`
  String get loginWithPhone {
    return Intl.message(
      'login with phone',
      name: 'loginWithPhone',
      desc: '',
      args: [],
    );
  }

  /// `delete`
  String get delete {
    return Intl.message(
      'delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `delete failed`
  String get failedToDelete {
    return Intl.message(
      'delete failed',
      name: 'failedToDelete',
      desc: '',
      args: [],
    );
  }

  /// `add to playlist`
  String get addToPlaylist {
    return Intl.message(
      'add to playlist',
      name: 'addToPlaylist',
      desc: '',
      args: [],
    );
  }

  /// `add to playlist failed`
  String get addToPlaylistFailed {
    return Intl.message(
      'add to playlist failed',
      name: 'addToPlaylistFailed',
      desc: '',
      args: [],
    );
  }

  /// `play in next`
  String get playInNext {
    return Intl.message(
      'play in next',
      name: 'playInNext',
      desc: '',
      args: [],
    );
  }

  /// `Skip login`
  String get skipLogin {
    return Intl.message(
      'Skip login',
      name: 'skipLogin',
      desc: '',
      args: [],
    );
  }

  /// `OpenSource project https://github.com/boyan01/flutter-netease-music`
  String get projectDescription {
    return Intl.message(
      'OpenSource project https://github.com/boyan01/flutter-netease-music',
      name: 'projectDescription',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `My Music`
  String get myMusic {
    return Intl.message(
      'My Music',
      name: 'myMusic',
      desc: '',
      args: [],
    );
  }

  /// `Personal FM`
  String get personalFM {
    return Intl.message(
      'Personal FM',
      name: 'personalFM',
      desc: '',
      args: [],
    );
  }

  /// `failed to play music`
  String get failedToPlayMusic {
    return Intl.message(
      'failed to play music',
      name: 'failedToPlayMusic',
      desc: '',
      args: [],
    );
  }

  /// `no music`
  String get noMusic {
    return Intl.message(
      'no music',
      name: 'noMusic',
      desc: '',
      args: [],
    );
  }

  /// `PlayList`
  String get playlist {
    return Intl.message(
      'PlayList',
      name: 'playlist',
      desc: '',
      args: [],
    );
  }

  /// `failed to load`
  String get failedToLoad {
    return Intl.message(
      'failed to load',
      name: 'failedToLoad',
      desc: '',
      args: [],
    );
  }

  /// `Library`
  String get library {
    return Intl.message(
      'Library',
      name: 'library',
      desc: '',
      args: [],
    );
  }

  /// `Recommend PlayLists`
  String get recommendPlayLists {
    return Intl.message(
      'Recommend PlayLists',
      name: 'recommendPlayLists',
      desc: '',
      args: [],
    );
  }

  /// `Please login first.`
  String get errorNotLogin {
    return Intl.message(
      'Please login first.',
      name: 'errorNotLogin',
      desc: '',
      args: [],
    );
  }

  /// `Track Count: {value}`
  String playlistTrackCount(Object value) {
    return Intl.message(
      'Track Count: $value',
      name: 'playlistTrackCount',
      desc: '',
      args: [value],
    );
  }

  /// `Play Count: {value}`
  String playlistPlayCount(Object value) {
    return Intl.message(
      'Play Count: $value',
      name: 'playlistPlayCount',
      desc: '',
      args: [value],
    );
  }

  /// `Music Name`
  String get musicName {
    return Intl.message(
      'Music Name',
      name: 'musicName',
      desc: '',
      args: [],
    );
  }

  /// `Artists`
  String get artists {
    return Intl.message(
      'Artists',
      name: 'artists',
      desc: '',
      args: [],
    );
  }

  /// `Album`
  String get album {
    return Intl.message(
      'Album',
      name: 'album',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get duration {
    return Intl.message(
      'Duration',
      name: 'duration',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message(
      'Theme',
      name: 'theme',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get themeDark {
    return Intl.message(
      'Dark',
      name: 'themeDark',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get themeLight {
    return Intl.message(
      'Light',
      name: 'themeLight',
      desc: '',
      args: [],
    );
  }

  /// `Follow System`
  String get themeAuto {
    return Intl.message(
      'Follow System',
      name: 'themeAuto',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Track No Copyright`
  String get trackNoCopyright {
    return Intl.message(
      'Track No Copyright',
      name: 'trackNoCopyright',
      desc: '',
      args: [],
    );
  }

  /// `Track only for VIP`
  String get trackVIP {
    return Intl.message(
      'Track only for VIP',
      name: 'trackVIP',
      desc: '',
      args: [],
    );
  }

  /// `noCopyright`
  String get tipNoCopyright {
    return Intl.message(
      'noCopyright',
      name: 'tipNoCopyright',
      desc: '',
      args: [],
    );
  }

  /// `VIP`
  String get tipVIP {
    return Intl.message(
      'VIP',
      name: 'tipVIP',
      desc: '',
      args: [],
    );
  }

  /// `No Lyric`
  String get noLyric {
    return Intl.message(
      'No Lyric',
      name: 'noLyric',
      desc: '',
      args: [],
    );
  }

  /// `Shortcuts`
  String get shortcuts {
    return Intl.message(
      'Shortcuts',
      name: 'shortcuts',
      desc: '',
      args: [],
    );
  }

  /// `Play/Pause`
  String get playOrPause {
    return Intl.message(
      'Play/Pause',
      name: 'playOrPause',
      desc: '',
      args: [],
    );
  }

  /// `Skip to Next`
  String get skipToNext {
    return Intl.message(
      'Skip to Next',
      name: 'skipToNext',
      desc: '',
      args: [],
    );
  }

  /// `Skip to Previous`
  String get skipToPrevious {
    return Intl.message(
      'Skip to Previous',
      name: 'skipToPrevious',
      desc: '',
      args: [],
    );
  }

  /// `Volume Up`
  String get volumeUp {
    return Intl.message(
      'Volume Up',
      name: 'volumeUp',
      desc: '',
      args: [],
    );
  }

  /// `Volume Down`
  String get volumeDown {
    return Intl.message(
      'Volume Down',
      name: 'volumeDown',
      desc: '',
      args: [],
    );
  }

  /// `Like Music`
  String get likeMusic {
    return Intl.message(
      'Like Music',
      name: 'likeMusic',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get functionDescription {
    return Intl.message(
      'Description',
      name: 'functionDescription',
      desc: '',
      args: [],
    );
  }

  /// `Space`
  String get keySpace {
    return Intl.message(
      'Space',
      name: 'keySpace',
      desc: '',
      args: [],
    );
  }

  /// `Play`
  String get play {
    return Intl.message(
      'Play',
      name: 'play',
      desc: '',
      args: [],
    );
  }

  /// `Pause`
  String get pause {
    return Intl.message(
      'Pause',
      name: 'pause',
      desc: '',
      args: [],
    );
  }

  /// `Playing List`
  String get playingList {
    return Intl.message(
      'Playing List',
      name: 'playingList',
      desc: '',
      args: [],
    );
  }

  /// `Personal FM Playing`
  String get personalFmPlaying {
    return Intl.message(
      'Personal FM Playing',
      name: 'personalFmPlaying',
      desc: '',
      args: [],
    );
  }

  /// `Play All`
  String get playAll {
    return Intl.message(
      'Play All',
      name: 'playAll',
      desc: '',
      args: [],
    );
  }

  /// `{value} Music`
  String musicCountFormat(Object value) {
    return Intl.message(
      '$value Music',
      name: 'musicCountFormat',
      desc: '',
      args: [value],
    );
  }

  /// `Select the artist`
  String get selectTheArtist {
    return Intl.message(
      'Select the artist',
      name: 'selectTheArtist',
      desc: '',
      args: [],
    );
  }

  /// `Created at {value}`
  String createdDate(Object value) {
    return Intl.message(
      'Created at $value',
      name: 'createdDate',
      desc: '',
      args: [value],
    );
  }

  /// `Subscribe`
  String get subscribe {
    return Intl.message(
      'Subscribe',
      name: 'subscribe',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Search Songs`
  String get searchPlaylistSongs {
    return Intl.message(
      'Search Songs',
      name: 'searchPlaylistSongs',
      desc: '',
      args: [],
    );
  }

  /// `Skip accompaniment when play playlist.`
  String get skipAccompaniment {
    return Intl.message(
      'Skip accompaniment when play playlist.',
      name: 'skipAccompaniment',
      desc: '',
      args: [],
    );
  }

  /// `Daily Recommend`
  String get dailyRecommend {
    return Intl.message(
      'Daily Recommend',
      name: 'dailyRecommend',
      desc: '',
      args: [],
    );
  }

  /// `Daily recommend music from Netease cloud music. Refresh every day at 06:00.`
  String get dailyRecommendDescription {
    return Intl.message(
      'Daily recommend music from Netease cloud music. Refresh every day at 06:00.',
      name: 'dailyRecommendDescription',
      desc: '',
      args: [],
    );
  }

  /// `Current Playing`
  String get currentPlaying {
    return Intl.message(
      'Current Playing',
      name: 'currentPlaying',
      desc: '',
      args: [],
    );
  }

  /// `Find {value} music`
  String searchMusicResultCount(Object value) {
    return Intl.message(
      'Find $value music',
      name: 'searchMusicResultCount',
      desc: '',
      args: [value],
    );
  }

  /// `Songs`
  String get songs {
    return Intl.message(
      'Songs',
      name: 'songs',
      desc: '',
      args: [],
    );
  }

  /// `Music Count`
  String get cloudMusicUsage {
    return Intl.message(
      'Music Count',
      name: 'cloudMusicUsage',
      desc: '',
      args: [],
    );
  }

  /// `Drop your music file to here to upload.`
  String get cloudMusicFileDropDescription {
    return Intl.message(
      'Drop your music file to here to upload.',
      name: 'cloudMusicFileDropDescription',
      desc: '',
      args: [],
    );
  }

  /// `random`
  String get repeatModeRandom {
    return Intl.message(
      'random',
      name: 'repeatModeRandom',
      desc: '',
      args: [],
    );
  }

  /// `circle`
  String get repeatModeNext {
    return Intl.message(
      'circle',
      name: 'repeatModeNext',
      desc: '',
      args: [],
    );
  }

  /// `single repeat`
  String get repeatModeOne {
    return Intl.message(
      'single repeat',
      name: 'repeatModeOne',
      desc: '',
      args: [],
    );
  }

  /// `stop after finish`
  String get repeatModeNone {
    return Intl.message(
      'stop after finish',
      name: 'repeatModeNone',
      desc: '',
      args: [],
    );
  }

  /// `{value} downloaded`
  String musicDownloading(Object value) {
    return Intl.message(
      '$value downloaded',
      name: 'musicDownloading',
      desc: '',
      args: [value],
    );
  }

  /// `{value} downloading`
  String musicDownloaded(Object value) {
    return Intl.message(
      '$value downloading',
      name: 'musicDownloaded',
      desc: '',
      args: [value],
    );
  }

  /// `{value} download fail`
  String musicDownloadFail(Object value) {
    return Intl.message(
      '$value download fail',
      name: 'musicDownloadFail',
      desc: '',
      args: [value],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
