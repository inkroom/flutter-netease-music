// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) => "Album: ${count}";

  static String m1(artistName, albumName, albumId, sharedUserId) =>
      "The ${artistName}\'s album《${albumName}》: http://music.163.com/album/${albumId}/?userid=${sharedUserId} (From @NeteaseCouldMusic)";

  static String m2(value) => "Created at ${value}";

  static String m3(name) => "Remove ${name} From Music List ?";

  static String m4(value) => "${value} Music";

  static String m5(value) => "${value} download fail";

  static String m6(value) => "${value} downloading";

  static String m7(value) => "${value} downloaded";

  static String m8(value) => "Play Count: ${value}";

  static String m9(username, title, playlistId, userId, shareUserId) =>
      "The PlayList created by ${username}「${title}」: http://music.163.com/playlist/${playlistId}/${userId}/?userid=${shareUserId} (From @NeteaseCouldMusic)";

  static String m10(value) => "Track Count: ${value}";

  static String m11(value) => "Find ${value} music";

  static String m12(version) => "New Version ${version}, Updating";

  static String m13(appName) => "${appName} is updating";

  static String m14(count) => "Video : ${count}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("About"),
        "addToMusicList":
            MessageLookupByLibrary.simpleMessage("Add To Music List"),
        "addToPlaylist":
            MessageLookupByLibrary.simpleMessage("add to playlist"),
        "addToPlaylistFailed":
            MessageLookupByLibrary.simpleMessage("add to playlist failed"),
        "album": MessageLookupByLibrary.simpleMessage("Album"),
        "albumCount": m0,
        "albumShareContent": m1,
        "alertAppLaunched":
            MessageLookupByLibrary.simpleMessage("App Has Launched"),
        "alreadyBuy": MessageLookupByLibrary.simpleMessage("Payed"),
        "alterActionClose": MessageLookupByLibrary.simpleMessage("Close"),
        "applicationLegalese":
            MessageLookupByLibrary.simpleMessage("Only For Special Person"),
        "artistInfo": MessageLookupByLibrary.simpleMessage("Artist"),
        "artists": MessageLookupByLibrary.simpleMessage("Artists"),
        "autoPlayOnStart":
            MessageLookupByLibrary.simpleMessage("auto play after start"),
        "checkUpdate": MessageLookupByLibrary.simpleMessage("Checking Update"),
        "cloudMusic": MessageLookupByLibrary.simpleMessage("Music List"),
        "cloudMusicFileDropDescription": MessageLookupByLibrary.simpleMessage(
            "Drop your music file to here to upload."),
        "cloudMusicUsage": MessageLookupByLibrary.simpleMessage("Music Count"),
        "collectionLike": MessageLookupByLibrary.simpleMessage("Collections"),
        "createdDate": m2,
        "createdSongList":
            MessageLookupByLibrary.simpleMessage("Created Song List"),
        "currentPlaying":
            MessageLookupByLibrary.simpleMessage("Current Playing"),
        "dailyRecommend":
            MessageLookupByLibrary.simpleMessage("Daily Recommend"),
        "dailyRecommendDescription": MessageLookupByLibrary.simpleMessage(
            "Daily recommend music from Netease cloud music. Refresh every day at 06:00."),
        "delete": MessageLookupByLibrary.simpleMessage("delete"),
        "deleteTrackConfirm": m3,
        "discover": MessageLookupByLibrary.simpleMessage("Discover"),
        "downloadMusic": MessageLookupByLibrary.simpleMessage("Download Music"),
        "duration": MessageLookupByLibrary.simpleMessage("Duration"),
        "emptyList":
            MessageLookupByLibrary.simpleMessage("The Music List Is Empty"),
        "errorNotLogin":
            MessageLookupByLibrary.simpleMessage("Please login first."),
        "errorToFetchData":
            MessageLookupByLibrary.simpleMessage("error to fetch data."),
        "exportFail": MessageLookupByLibrary.simpleMessage("export fail"),
        "exported": MessageLookupByLibrary.simpleMessage("export success"),
        "failedToDelete": MessageLookupByLibrary.simpleMessage("delete failed"),
        "failedToLoad": MessageLookupByLibrary.simpleMessage("failed to load"),
        "failedToPlayMusic":
            MessageLookupByLibrary.simpleMessage("failed to play music"),
        "favoriteSongList":
            MessageLookupByLibrary.simpleMessage("Favorite Song List"),
        "friends": MessageLookupByLibrary.simpleMessage("Friends"),
        "functionDescription":
            MessageLookupByLibrary.simpleMessage("Description"),
        "getPlayDetailFail":
            MessageLookupByLibrary.simpleMessage("Fetch Music Failed"),
        "hotSong": MessageLookupByLibrary.simpleMessage("Hot Song"),
        "importFail": MessageLookupByLibrary.simpleMessage("import fail"),
        "imported": MessageLookupByLibrary.simpleMessage("import success"),
        "keySpace": MessageLookupByLibrary.simpleMessage("Space"),
        "latestPlayHistory":
            MessageLookupByLibrary.simpleMessage("Play History"),
        "library": MessageLookupByLibrary.simpleMessage("Library"),
        "likeMusic": MessageLookupByLibrary.simpleMessage("Like Music"),
        "localMusic": MessageLookupByLibrary.simpleMessage("Local Music"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "loginWithPhone":
            MessageLookupByLibrary.simpleMessage("login with phone"),
        "musicCountFormat": m4,
        "musicDownloadFail": m5,
        "musicDownloaded": m6,
        "musicDownloading": m7,
        "musicName": MessageLookupByLibrary.simpleMessage("Music Name"),
        "my": MessageLookupByLibrary.simpleMessage("My"),
        "myDjs": MessageLookupByLibrary.simpleMessage("Dj"),
        "myMusic": MessageLookupByLibrary.simpleMessage("My Music"),
        "needLogin": MessageLookupByLibrary.simpleMessage("Login First"),
        "networkNotAllow":
            MessageLookupByLibrary.simpleMessage("Network Setting"),
        "newestVersion": MessageLookupByLibrary.simpleMessage("Newest Version"),
        "nextStep": MessageLookupByLibrary.simpleMessage("next step"),
        "noLyric": MessageLookupByLibrary.simpleMessage("No Lyric"),
        "noMusic": MessageLookupByLibrary.simpleMessage("no music"),
        "pause": MessageLookupByLibrary.simpleMessage("Pause"),
        "personalFM": MessageLookupByLibrary.simpleMessage("Personal FM"),
        "personalFmPlaying":
            MessageLookupByLibrary.simpleMessage("Personal FM Playing"),
        "play": MessageLookupByLibrary.simpleMessage("Play"),
        "playAll": MessageLookupByLibrary.simpleMessage("Play All"),
        "playInNext": MessageLookupByLibrary.simpleMessage("play in next"),
        "playOrPause": MessageLookupByLibrary.simpleMessage("Play/Pause"),
        "playingList": MessageLookupByLibrary.simpleMessage("Playing List"),
        "playlist": MessageLookupByLibrary.simpleMessage("PlayList"),
        "playlistLoginDescription": MessageLookupByLibrary.simpleMessage(
            "Login to discover your playlists."),
        "playlistPlayCount": m8,
        "playlistShareContent": m9,
        "playlistTrackCount": m10,
        "projectDescription": MessageLookupByLibrary.simpleMessage(
            "OpenSource project https://github.com/boyan01/flutter-netease-music"),
        "recommendPlayLists":
            MessageLookupByLibrary.simpleMessage("Recommend PlayLists"),
        "removeFromMusicList":
            MessageLookupByLibrary.simpleMessage("Remove From Music List"),
        "repeatModeNext": MessageLookupByLibrary.simpleMessage("circle"),
        "repeatModeNone":
            MessageLookupByLibrary.simpleMessage("stop after finish"),
        "repeatModeOne": MessageLookupByLibrary.simpleMessage("single repeat"),
        "repeatModeRandom": MessageLookupByLibrary.simpleMessage("random"),
        "savePath": MessageLookupByLibrary.simpleMessage("The File Save Path"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "searchMusicResultCount": m11,
        "searchPlaylistSongs":
            MessageLookupByLibrary.simpleMessage("Search Songs"),
        "selectRegionDiaCode":
            MessageLookupByLibrary.simpleMessage("select region code"),
        "selectTheArtist":
            MessageLookupByLibrary.simpleMessage("Select the artist"),
        "settingExport": MessageLookupByLibrary.simpleMessage("Export"),
        "settingExportIng": MessageLookupByLibrary.simpleMessage("Exporting"),
        "settingImport": MessageLookupByLibrary.simpleMessage("Import"),
        "settingImportIng": MessageLookupByLibrary.simpleMessage("Importing"),
        "settingItemGroupNetwork":
            MessageLookupByLibrary.simpleMessage("Network"),
        "settingItemNoNetwork":
            MessageLookupByLibrary.simpleMessage("No Network"),
        "settingItemOnlyMobile":
            MessageLookupByLibrary.simpleMessage("Use 3/4/5G"),
        "settingItemOnlyWIFI":
            MessageLookupByLibrary.simpleMessage("Only WIFI"),
        "settingNetwork":
            MessageLookupByLibrary.simpleMessage("Network Setting"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "share": MessageLookupByLibrary.simpleMessage("Share"),
        "shareContentCopied": MessageLookupByLibrary.simpleMessage(
            "Share content has copied to clipboard."),
        "shortcuts": MessageLookupByLibrary.simpleMessage("Shortcuts"),
        "skipAccompaniment": MessageLookupByLibrary.simpleMessage(
            "Skip accompaniment when play playlist."),
        "skipLogin": MessageLookupByLibrary.simpleMessage("Skip login"),
        "skipToNext": MessageLookupByLibrary.simpleMessage("Skip to Next"),
        "skipToPrevious":
            MessageLookupByLibrary.simpleMessage("Skip to Previous"),
        "songs": MessageLookupByLibrary.simpleMessage("Songs"),
        "subscribe": MessageLookupByLibrary.simpleMessage("Subscribe"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "themeAuto": MessageLookupByLibrary.simpleMessage("Follow System"),
        "themeDark": MessageLookupByLibrary.simpleMessage("Dark"),
        "themeLight": MessageLookupByLibrary.simpleMessage("Light"),
        "tipNoCopyright": MessageLookupByLibrary.simpleMessage("noCopyright"),
        "tipVIP": MessageLookupByLibrary.simpleMessage("VIP"),
        "tipsAutoRegisterIfUserNotExist": MessageLookupByLibrary.simpleMessage(
            "auto register if phone not exist"),
        "toLoginPage": MessageLookupByLibrary.simpleMessage("To Login Page"),
        "todo": MessageLookupByLibrary.simpleMessage("TBD"),
        "trackFlagSetting":
            MessageLookupByLibrary.simpleMessage("Set Track Flag"),
        "trackNoCopyright":
            MessageLookupByLibrary.simpleMessage("Track No Copyright"),
        "trackVIP": MessageLookupByLibrary.simpleMessage("Track only for VIP"),
        "trayItemExit": MessageLookupByLibrary.simpleMessage("Exit"),
        "trayItemHide": MessageLookupByLibrary.simpleMessage("Hide"),
        "trayItemShow": MessageLookupByLibrary.simpleMessage("Show"),
        "unsupportedOrigin":
            MessageLookupByLibrary.simpleMessage("Unsupported Origin"),
        "updateFail": MessageLookupByLibrary.simpleMessage("Update Fail"),
        "updateTip": m12,
        "updateTitle": m13,
        "videoCount": m14,
        "volumeDown": MessageLookupByLibrary.simpleMessage("Volume Down"),
        "volumeUp": MessageLookupByLibrary.simpleMessage("Volume Up")
      };
}
