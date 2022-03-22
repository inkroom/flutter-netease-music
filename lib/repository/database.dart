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
        .then((value) => join(value!.path, 'binary'));
  } else {
    return getApplicationDocumentsDirectory()
        .then((value) => join(value.path, 'quiet', 'binary'));
  }
}

Future<String> getCookieDirectory() {
  return getApplicationDocumentsDirectory()
      .then((value) => join(value.path, 'quiet', 'cookie'));
}

Future<String> getCacheDirectory() {
  return getApplicationDocumentsDirectory()
      .then((value) => join(value.path, 'quiet', 'cache'));
}
