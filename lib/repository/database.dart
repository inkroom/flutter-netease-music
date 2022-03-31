import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

export 'package:sembast/sembast.dart';
export 'package:sembast/sembast_io.dart';

Database? _db;

///Quiet application database
Future<Database> getApplicationDatabase() async {
  if (Platform.isAndroid) {
    final p = (await getExternalStorageDirectory())?.path;
    if (p != null) {
      return _db ??=
          await databaseFactoryIo.openDatabase(join(p, 'quiet', 'quiet.db'));
    }
  }
  return _db ??= await databaseFactoryIo.openDatabase(join(
      (await getApplicationDocumentsDirectory()).path, 'quiet', 'quiet.db'));
}

/// 获取二进制文件存储位置
Future<String> getApplicationBin() {
  Future<Directory> p = getApplicationDocumentsDirectory();
  if (Platform.isAndroid) {
    p = getExternalStorageDirectory().then((value) => value == null
        ? getApplicationDocumentsDirectory()
        : Future.value(value));
  }
  return p.then((value) => join(value.path, 'quiet', 'binary')).then(_checkDir);
}

Future<String> getCookieDirectory() {
  Future<Directory> p = getApplicationDocumentsDirectory();
  if (Platform.isAndroid) {
    p = getExternalStorageDirectory().then((value) => value == null
        ? getApplicationDocumentsDirectory()
        : Future.value(value));
  }
  return p.then((value) => join(value.path, 'quiet', 'cookie')).then(_checkDir);
}

Future<String> getCacheDirectory() {
  Future<Directory> p = getApplicationDocumentsDirectory();
  if (Platform.isAndroid) {
    p = getExternalStorageDirectory().then((value) => value == null
        ? getApplicationDocumentsDirectory()
        : Future.value(value));
  }
  return p.then((value) => join(value.path, 'quiet', 'cache')).then(_checkDir);
}

/// 图片缓存路径
Future<String> getThumbDirectory() {
  Future<Directory> p = getApplicationDocumentsDirectory();
  if (Platform.isAndroid) {
    p = getExternalStorageDirectory().then((value) => value == null
        ? getApplicationDocumentsDirectory()
        : Future.value(value));
  }
  return p.then((value) => join(value.path, 'quiet', 'images')).then(_checkDir);
}

/// 歌词文件缓存位置
Future<String> getLyricDirectory() {
  Future<Directory> p = getApplicationDocumentsDirectory();
  if (Platform.isAndroid) {
    p = getExternalStorageDirectory().then((value) => value == null
        ? getApplicationDocumentsDirectory()
        : Future.value(value));
  }
  return p.then((value) => join(value.path, 'quiet', 'lyrics')).then(_checkDir);
}

/// 安装包下载位置
///
Future<String> getApkDirectory() {
  if(Platform.isWindows){
    return getCacheDirectory();
  }

  return getExternalStorageDirectory()
      .then((value) => value == null
          ? getApplicationDocumentsDirectory()
          : Future.value(value))
  /// 这里路径不能随便改，要改需要把 android/app/res/xml/update_path.xml 里的一起改了，否则软件包安装会失败
      .then((value) => join(value.path, 'quiet', 'apks'))
      .then(_checkDir);
}

/// 校验并创建目录
Future<String> _checkDir(String path) {
  var d = Directory(path);
  return d.create(recursive: true).then((value) => value.path);
}
