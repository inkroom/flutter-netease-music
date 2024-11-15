import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/material.dart';
import 'package:quiet/providers/settings_provider.dart';
import 'package:quiet/repository/database.dart';
import 'package:quiet/repository/netease.dart';
import 'package:url_launcher_linux/url_launcher_linux.dart' as url_linux;
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:url_launcher_windows/url_launcher_windows.dart' as url_windows;
// 软件更新dialog

/// [path] 文件位置，可以拿来安装
typedef OnDownloadComplete = void Function(String path);
typedef OnDownloadFail = void Function(String msg);
typedef OnCheckVersion = void Function(bool shouldUpdate);

void updateApp(BuildContext context, {OnCheckVersion? onCheckVersion}) {
  if (!kReleaseMode) return;

  /// 当前只支持android平台自动更新，windows平台自动打开网页下载最新版
  if (NetworkSingleton.instance.allowNetwork()) {
    PackageInfo.fromPlatform()
        .then((value) => _getUpdateUrl(value))
        .then((value) {
      if (value == null) {
        toast(S.current.updateFail);
        return;
      }
      if (value.toString() == '') {
        if (onCheckVersion != null) onCheckVersion(false);
        return;
      }

      // 更新
      if (Platform.isWindows || Platform.isLinux) {
        if (value[Platform.operatingSystem]['url'] != null &&
            value[Platform.operatingSystem]['url'] != '') {
          final UrlLauncherPlatform urlLauncherPlatform;
          if (Platform.isWindows) {
            urlLauncherPlatform = url_windows.UrlLauncherWindows();
          } else {
            urlLauncherPlatform = url_linux.UrlLauncherLinux();
          }
          urlLauncherPlatform.launch(
              ("${value[Platform.operatingSystem]['url']}"),
              useSafariVC: true,
              useWebView: false,
              enableJavaScript: true,
              enableDomStorage: true,
              universalLinksOnly: false,
              headers: {});
        }
      } else if (Platform.isAndroid) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return WillPopScope(
                  child: _UpdateDialogContent(
                    url: value[Platform.operatingSystem]['url'],
                    filename: value[Platform.operatingSystem]['file'],
                    version: value[Platform.operatingSystem]['version'],
                    onDownloadComplete: (filePath) {
                      log('下載的文件位置= $filePath');
                      // 唤起安装
                      MethodChannel("quiet.update.app.channel.install_app")
                          .invokeMethod("installApk", {"path": filePath});
                      // 关闭弹窗
                      Navigator.pop(context, "");
                    },
                    onDownloadFail: (msg) {
                      toast(S.current.updateFail);
                      // 关闭弹窗
                      Navigator.pop(context, "");
                    },
                  ),
                  onWillPop: () => Future.value(false));
            }).then((value) {
          log("dialog $value");
        }).catchError((error, s) {
          log("dialog $error $s");
        });
      }
    }).catchError((error, s) {
      toast(S.current.updateFail);
      log(s.toString());
      log(error);
    });
  }
}

///
/// 校验版本号
/// @return true代表低于新版本，false代表等于或高于新版本
bool _checkVersion(String newVersion, String oldVersion) {
  if (newVersion == oldVersion) return false;
  var newVersions = newVersion.split('.');
  var oldVersions = oldVersion.split('.');

  for (var i = 0; i < newVersions.length; i++) {
    if (int.parse(newVersions[i]) < int.parse(oldVersions[i])) {
      return false;
    } else if (int.parse(newVersions[i]) > int.parse(oldVersions[i])) {
      return true;
    }
  }
  return true;
}

Future<dynamic> _getUpdateUrl(PackageInfo info) {
  // 请求顺序 github -> cos -> minio

  return _getUpdateUrlFromGithub(info).catchError((error, s) {
    log("github error" + error.toString());
    log(error);

    return _getUpdateUrlFromCos(info);
  }).then((value) {
    return (value == null || value.toString() == '')
        ? _getUpdateUrlFromCos(info)
            .catchError((error, s) => _getUpdateUrlFromMinio(info))
        : value;
  }).then((value) {
    log("minio value " + value.toString());
    return value.toString() == '' ? _getUpdateUrlFromMinio(info) : value;
  });
}

/// 从minio检查更新
///
Future<dynamic> _getUpdateUrlFromMinio(PackageInfo info) {
  return networkRepository!.checkUpdate(1).then((value) {
    log("从minio获取更新 " + value.toString());
    if (value != null &&
        value[Platform.operatingSystem] != null &&
        value[Platform.operatingSystem]['version'] != null) {
      if (_checkVersion(
          value[Platform.operatingSystem]['version'], info.version)) {
        return Future.value(value);
      }
      return Future.value(''); //不更新
    }
    return Future.value(null); //检查更新失败
  });
}

/// 从cos检查更新
///
Future<dynamic> _getUpdateUrlFromCos(PackageInfo info) {
  return networkRepository!.checkUpdate(2).then((value) {
    if (value != null &&
        (value = ((value is String) ? jsonDecode(value) : value)) != null &&
        value[Platform.operatingSystem] != null &&
        value[Platform.operatingSystem]['version'] != null) {
      log("从cos获取更新 " + value.toString());
      if (_checkVersion(
          value[Platform.operatingSystem]['version'], info.version)) {
        log('cos 更新');
        return Future.value(value);
      }
      log("cos 不更新");
      return Future.value(''); //不更新
    }
    return Future.value(null); //检查更新失败
  });
}

/// 从github检查更新
///
Future<dynamic> _getUpdateUrlFromGithub(PackageInfo info) {
  return networkRepository!.checkUpdate(0).then((value) {
    if (value != null) {
      log("从github获取更新 " + value.toString());
      List assets = value['assets'];

      final version = {
        "linux": {
          "version": value['tag_name'].toString().substring(1),
          "description": "_desc_",
          "file": "quiet/quiet-linux-latest.deb",
          "url": assets
              .where((element) =>
                  element['name'].toString().contains(RegExp("linux")))
              .first['browser_download_url']
        },
        "windows": {
          "version": value['tag_name'].toString().substring(1),
          "description": "_desc_",
          "file": "quiet/quiet-windows-latest.zip",
          "url": assets
              .where((element) =>
                  element['name'].toString().contains(RegExp("windows")))
              .first['browser_download_url']
        },
        "android": {
          "version": value['tag_name'].toString().substring(1),
          "description": "_desc_",
          "file": "quiet/quiet-android-latest.apk",
          "url": assets
              .where((element) => element['name']
                  .toString()
                  .contains(RegExp("android-${value['tag_name']}.apk")))
              .first['browser_download_url']
        }
      };

      if (_checkVersion(
          version[Platform.operatingSystem]!['version'], info.version)) {
        return Future.value(version);
      }
      return Future.value(''); //不更新
    }
    return Future.value(null); //检查更新失败
  })
      //     .catchError((error, s) {
      //   return Future.value();
      // })
      ;
}

class _UpdateDialogContent extends StatefulWidget {
  const _UpdateDialogContent(
      {Key? key,
      required this.url,
      required this.filename,
      required this.version,
      required this.onDownloadComplete,
      required this.onDownloadFail})
      : super(key: key);

  final String url;
  final OnDownloadComplete onDownloadComplete;
  final OnDownloadFail onDownloadFail;
  final String filename;
  final String version;

  // @override
  // Widget build(BuildContext context, WidgetRef ref) {
  //   return UnconstrainedBox(
  //     child: SizedBox(
  //       child: LinearProgressIndicator(
  //         value: 60,
  //       ),
  //       width: 200,
  //       height: 200,
  //     ),
  //   );
  // }

  @override
  _UpdateDialogState createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialogContent> {
  double _processValue = 0;

  @override
  void initState() {
    super.initState();
    getApkDirectory().then((value) {
      Dio().download(widget.url, "$value/${widget.filename}",
              onReceiveProgress: (int count, int total) {
        setState(() {
          _processValue = count / total;
          if (_processValue >= 1) {
            widget.onDownloadComplete("$value/${widget.filename}");
          }
        });
      }).catchError((e) {
        widget.onDownloadFail(e.toString());
      }) //The error handler of Future.catchError must return a value of the future's type  这里会报个错，不知道怎么解决，反正也没什么影响，就不管了
          ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          child: CircularProgressIndicator(
            value: _processValue,
            color: Colors.red,
          ),
          width: 100,
          height: 100,
        ),
        Text(
          context.strings.updateTip(widget.version),
          style: context.textTheme.bodyMedium,
        )
      ],
    );
  }
}
