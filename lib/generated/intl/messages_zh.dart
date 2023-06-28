// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
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
  String get localeName => 'zh';

  static String m0(count) => "专辑${count}";

  static String m1(artistName, albumName, albumId, sharedUserId) =>
      "分享${artistName}的专辑《${albumName}》: http://music.163.com/album/${albumId}/?userid=${sharedUserId} (来自@网易云音乐)";

  static String m2(value) => "${value}创建";

  static String m3(name) => "是否从歌单中移除${name}？";

  static String m4(value) => "共${value}首";

  static String m5(value) => "${value} 下载失败";

  static String m6(value) => "${value} 下载完成";

  static String m7(value) => "${value} 开始下载";

  static String m8(value) => "播放数: ${value}";

  static String m9(username, title, playlistId, userId, shareUserId) =>
      "分享${username}创建的歌单「${title}」: http://music.163.com/playlist/${playlistId}/${userId}/?userid=${shareUserId} (来自@网易云音乐)";

  static String m10(value) => "歌曲数: ${value}";

  static String m11(value) => "找到 ${value} 首歌曲";

  static String m12(version) => "检测到新版本${version}，即将更新";

  static String m13(appName) => "${appName}正在更新";

  static String m14(count) => "视频${count}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "about": MessageLookupByLibrary.simpleMessage("关于"),
        "addToMusicList": MessageLookupByLibrary.simpleMessage("加入歌单"),
        "addToPlaylist": MessageLookupByLibrary.simpleMessage("加入歌单"),
        "addToPlaylistFailed": MessageLookupByLibrary.simpleMessage("加入歌单失败"),
        "album": MessageLookupByLibrary.simpleMessage("专辑"),
        "albumCount": m0,
        "albumShareContent": m1,
        "alertAppLaunched": MessageLookupByLibrary.simpleMessage("程序已运行"),
        "alreadyBuy": MessageLookupByLibrary.simpleMessage("收藏和赞"),
        "alterActionClose": MessageLookupByLibrary.simpleMessage("关闭"),
        "applicationLegalese": MessageLookupByLibrary.simpleMessage("仅供个人使用"),
        "artistInfo": MessageLookupByLibrary.simpleMessage("艺人信息"),
        "artists": MessageLookupByLibrary.simpleMessage("歌手"),
        "autoPlayOnStart": MessageLookupByLibrary.simpleMessage("启动后自动播放"),
        "checkUpdate": MessageLookupByLibrary.simpleMessage("检查更新"),
        "cloudMusic": MessageLookupByLibrary.simpleMessage("歌单"),
        "cloudMusicFileDropDescription":
            MessageLookupByLibrary.simpleMessage("将音乐文件拖放到这里进行上传"),
        "cloudMusicUsage": MessageLookupByLibrary.simpleMessage("歌曲数目"),
        "collectionLike": MessageLookupByLibrary.simpleMessage("已购"),
        "copyMusicName": MessageLookupByLibrary.simpleMessage("复制歌名"),
        "createdDate": m2,
        "createdSongList": MessageLookupByLibrary.simpleMessage("创建歌单"),
        "currentPlaying": MessageLookupByLibrary.simpleMessage("当前播放"),
        "dailyRecommend": MessageLookupByLibrary.simpleMessage("每日推荐"),
        "dailyRecommendDescription":
            MessageLookupByLibrary.simpleMessage("网易云音乐每日推荐歌曲，每天 6:00 更新。"),
        "delete": MessageLookupByLibrary.simpleMessage("删除"),
        "deleteTrackConfirm": m3,
        "discover": MessageLookupByLibrary.simpleMessage("发现"),
        "downloadMusic": MessageLookupByLibrary.simpleMessage("下载歌曲"),
        "duration": MessageLookupByLibrary.simpleMessage("时长"),
        "emptyList": MessageLookupByLibrary.simpleMessage("歌曲列表为空"),
        "errorNotLogin": MessageLookupByLibrary.simpleMessage("未登录"),
        "errorToFetchData": MessageLookupByLibrary.simpleMessage("获取数据失败"),
        "exportFail": MessageLookupByLibrary.simpleMessage("导出失败"),
        "exported": MessageLookupByLibrary.simpleMessage("导出完成"),
        "failedToDelete": MessageLookupByLibrary.simpleMessage("删除失败"),
        "failedToLoad": MessageLookupByLibrary.simpleMessage("加载失败"),
        "failedToPlayMusic": MessageLookupByLibrary.simpleMessage("播放音乐失败"),
        "favoriteSongList": MessageLookupByLibrary.simpleMessage("收藏歌单"),
        "friends": MessageLookupByLibrary.simpleMessage("我的好友"),
        "functionDescription": MessageLookupByLibrary.simpleMessage("功能描述"),
        "getPlayDetailFail": MessageLookupByLibrary.simpleMessage("获取歌曲详情失败"),
        "hotSong": MessageLookupByLibrary.simpleMessage("热门单曲"),
        "importFail": MessageLookupByLibrary.simpleMessage("导入失败"),
        "imported": MessageLookupByLibrary.simpleMessage("导入完成"),
        "keySpace": MessageLookupByLibrary.simpleMessage("空格"),
        "latestPlayHistory": MessageLookupByLibrary.simpleMessage("最近播放"),
        "library": MessageLookupByLibrary.simpleMessage("音乐库"),
        "likeMusic": MessageLookupByLibrary.simpleMessage("喜欢歌曲"),
        "localMusic": MessageLookupByLibrary.simpleMessage("本地音乐"),
        "login": MessageLookupByLibrary.simpleMessage("立即登录"),
        "loginWithPhone": MessageLookupByLibrary.simpleMessage("手机号登录"),
        "musicCountFormat": m4,
        "musicDownloadFail": m5,
        "musicDownloaded": m6,
        "musicDownloading": m7,
        "musicName": MessageLookupByLibrary.simpleMessage("歌曲名"),
        "my": MessageLookupByLibrary.simpleMessage("我的"),
        "myDjs": MessageLookupByLibrary.simpleMessage("我的电台"),
        "myMusic": MessageLookupByLibrary.simpleMessage("我的音乐"),
        "needLogin": MessageLookupByLibrary.simpleMessage("需要登录"),
        "networkNotAllow": MessageLookupByLibrary.simpleMessage("当前网络设置不允许"),
        "newestVersion": MessageLookupByLibrary.simpleMessage("已是最新版本"),
        "nextStep": MessageLookupByLibrary.simpleMessage("下一步"),
        "noLyric": MessageLookupByLibrary.simpleMessage("暂无歌词"),
        "noMusic": MessageLookupByLibrary.simpleMessage("暂无音乐"),
        "pause": MessageLookupByLibrary.simpleMessage("暂停"),
        "personalFM": MessageLookupByLibrary.simpleMessage("私人FM"),
        "personalFmPlaying": MessageLookupByLibrary.simpleMessage("私人FM播放中"),
        "play": MessageLookupByLibrary.simpleMessage("播放"),
        "playAll": MessageLookupByLibrary.simpleMessage("全部播放"),
        "playInNext": MessageLookupByLibrary.simpleMessage("下一首播放"),
        "playOrPause": MessageLookupByLibrary.simpleMessage("播放/暂停"),
        "playingList": MessageLookupByLibrary.simpleMessage("当前播放列表"),
        "playlist": MessageLookupByLibrary.simpleMessage("歌单"),
        "playlistLoginDescription":
            MessageLookupByLibrary.simpleMessage("登录以加载你的私人播放列表。"),
        "playlistPlayCount": m8,
        "playlistShareContent": m9,
        "playlistTrackCount": m10,
        "projectDescription": MessageLookupByLibrary.simpleMessage(
            "开源项目 https://github.com/boyan01/flutter-netease-music"),
        "recommendPlayLists": MessageLookupByLibrary.simpleMessage("推荐歌单"),
        "removeFromMusicList": MessageLookupByLibrary.simpleMessage("移除歌单"),
        "repeatModeNext": MessageLookupByLibrary.simpleMessage("列表循环"),
        "repeatModeNone": MessageLookupByLibrary.simpleMessage("播放完停止"),
        "repeatModeOne": MessageLookupByLibrary.simpleMessage("单曲循环"),
        "repeatModeRandom": MessageLookupByLibrary.simpleMessage("随机播放"),
        "savePath": MessageLookupByLibrary.simpleMessage("文件保存位置"),
        "search": MessageLookupByLibrary.simpleMessage("搜索"),
        "searchMusicResultCount": m11,
        "searchPlaylistSongs": MessageLookupByLibrary.simpleMessage("搜索歌单歌曲"),
        "selectRegionDiaCode": MessageLookupByLibrary.simpleMessage("选择地区号码"),
        "selectTheArtist": MessageLookupByLibrary.simpleMessage("请选择要查看的歌手"),
        "settingExport": MessageLookupByLibrary.simpleMessage("导出"),
        "settingExportIng": MessageLookupByLibrary.simpleMessage("导出中"),
        "settingImport": MessageLookupByLibrary.simpleMessage("导入"),
        "settingImportIng": MessageLookupByLibrary.simpleMessage("导入中"),
        "settingItemGroupNetwork": MessageLookupByLibrary.simpleMessage("网络"),
        "settingItemNoNetwork": MessageLookupByLibrary.simpleMessage("不可联网"),
        "settingItemOnlyMobile":
            MessageLookupByLibrary.simpleMessage("可使用流量网络"),
        "settingItemOnlyWIFI":
            MessageLookupByLibrary.simpleMessage("仅使用WIFI网络"),
        "settingNetwork": MessageLookupByLibrary.simpleMessage("联网设置"),
        "settingPlayFlagTitle":
            MessageLookupByLibrary.simpleMessage("可播放的歌曲标记"),
        "settings": MessageLookupByLibrary.simpleMessage("设置"),
        "share": MessageLookupByLibrary.simpleMessage("分享"),
        "shareContentCopied":
            MessageLookupByLibrary.simpleMessage("分享内容已复制到剪切板"),
        "shortcuts": MessageLookupByLibrary.simpleMessage("快捷键"),
        "skipAccompaniment":
            MessageLookupByLibrary.simpleMessage("播放歌单时跳过包含伴奏的歌曲"),
        "skipLogin": MessageLookupByLibrary.simpleMessage("跳过登录"),
        "skipToNext": MessageLookupByLibrary.simpleMessage("下一首"),
        "skipToPrevious": MessageLookupByLibrary.simpleMessage("上一首"),
        "songs": MessageLookupByLibrary.simpleMessage("歌曲"),
        "subscribe": MessageLookupByLibrary.simpleMessage("收藏"),
        "theme": MessageLookupByLibrary.simpleMessage("主题"),
        "themeAuto": MessageLookupByLibrary.simpleMessage("跟随系统"),
        "themeDark": MessageLookupByLibrary.simpleMessage("深色主题"),
        "themeLight": MessageLookupByLibrary.simpleMessage("浅色主题"),
        "tipNoCopyright": MessageLookupByLibrary.simpleMessage("无版权"),
        "tipVIP": MessageLookupByLibrary.simpleMessage("VIP"),
        "tipsAutoRegisterIfUserNotExist":
            MessageLookupByLibrary.simpleMessage("未注册手机号登陆后将自动创建账号"),
        "toLoginPage": MessageLookupByLibrary.simpleMessage("前往登录界面"),
        "todo": MessageLookupByLibrary.simpleMessage("TBD"),
        "trackFlagSetting": MessageLookupByLibrary.simpleMessage("歌曲标记"),
        "trackNoCopyright": MessageLookupByLibrary.simpleMessage("此音乐暂无版权"),
        "trackVIP": MessageLookupByLibrary.simpleMessage("此音乐为VIP"),
        "trayItemExit": MessageLookupByLibrary.simpleMessage("退出程序"),
        "trayItemHide": MessageLookupByLibrary.simpleMessage("隐藏窗口"),
        "trayItemShow": MessageLookupByLibrary.simpleMessage("显示窗口"),
        "unsupportedOrigin": MessageLookupByLibrary.simpleMessage("不支持的来源"),
        "updateFail": MessageLookupByLibrary.simpleMessage("更新失败"),
        "updateTip": m12,
        "updateTitle": m13,
        "videoCount": m14,
        "volumeDown": MessageLookupByLibrary.simpleMessage("音量-"),
        "volumeUp": MessageLookupByLibrary.simpleMessage("音量+")
      };
}
