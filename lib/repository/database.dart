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
  return _db ??= await databaseFactoryIo.openDatabase(join(
      (await getApplicationDocumentsDirectory()).path, 'quiet', 'quiet.db'));
}

/// 获取二进制文件存储位置
Future<String> getApplicationBin() {
  if (Platform.isAndroid) {
    return getExternalStorageDirectory()
        .then((value) => join(value!.path, 'quiet', 'binary'))
        .then((value) => _checkDir(value));
  } else {
    return getApplicationDocumentsDirectory()
        .then((value) => join(value.path, 'quiet', 'binary'))
        .then((value) => _checkDir(value));
  }
}

Future<String> getCookieDirectory() {
  return getApplicationDocumentsDirectory()
      .then((value) => join(value.path, 'quiet', 'cookie'))
      .then((value) => _checkDir(value));
}

Future<String> getCacheDirectory() {
  return getApplicationDocumentsDirectory()
      .then((value) => join(value.path, 'quiet', 'cache'))
      .then((value) => _checkDir(value));
}

/// 图片缓存路径
Future<String> getThumbDirectory() {
  return getTemporaryDirectory()
      .then((value) => join(value.path, 'quiet', 'images'))
      .then((value) => _checkDir(value));
}

/// 校验并创建目录
Future<String> _checkDir(String path) {
  var d = Directory(path);
  return d.create(recursive: true).then((value) => value.path);
}
