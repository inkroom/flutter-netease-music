import 'dart:io';

import 'package:path/path.dart';
import 'package:quiet/repository/database.dart';

/// 用来判断程序是否有已运行的程序
///
/// 原理是对文件加锁，获取锁失败即有实例运行
///

class SingleApp {
  SingleApp._();

  static final SingleApp instance = SingleApp._();

  RandomAccessFile? file;
  File? f;

  /// 尝试获取锁，获取失败，即程序已运行
  ///
  Future<bool> lock() {
    return getCacheDirectory()
        .then((value) => join(value, 'lock.lock'))
        .then((value) => File(value))
        .then((value) => f = value)
        .then((value) => value.open(mode: FileMode.write))
        .then((value) => value.lock())
        .then((value) => file = value)
        .then((value) => true)
        .catchError((onError) => false);
  }

  /// 释放锁，务必在退出程序前调用该方法，没有获取到锁就不用调用了
  Future<bool> release() {
    if (file == null || f == null) {
      return Future.value(false);
    }
    return file!
        .unlock()
        .then((value) => value.close())
        .then((value) => f!.delete())
        .then((value) => true);
  }
}
