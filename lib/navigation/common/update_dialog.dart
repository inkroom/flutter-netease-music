import 'dart:developer';
import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiet/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quiet/providers/settings_provider.dart';
import 'package:quiet/repository/database.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/repository/netease.dart';
import 'package:url_launcher/url_launcher.dart';

// 软件更新dialog

/// [path] 文件位置，可以拿来安装
typedef OnDownloadComplete = void Function(String path);
typedef OnDownloadFail = void Function(String msg);
typedef OnCheckVersion = void Function(bool shouldUpdate);

void updateApp(BuildContext context, {OnCheckVersion? onCheckVersion}) {
  if (!kReleaseMode) return;

  /// 当前只支持android平台自动更新，windows平台自动打开网页下载最新版
  if (NetworkSingleton.instance.allowNetwork()) {
    PackageInfo? info;
    PackageInfo.fromPlatform()
        .then((value) => info = value)
        .then((value) => _getUpdateUrlFromMinio(value))
        .catchError((error, s) => _getUpdateUrlFromGithub(info!))
        .then((value) {
      if (value == null) {
        toast(S.current.updateFail);
        return;
      }
      if (value == '') {
        if (onCheckVersion != null) onCheckVersion(false);
        return;
      }
      // 更新
      if (Platform.isWindows || Platform.isLinux) {
        if (value[Platform.operatingSystem]['url'] != null &&
            value[Platform.operatingSystem]['url'] != '') {
          launchUrl(Uri.parse("${value[Platform.operatingSystem]['url']}"));
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
    });
  }
}

/// 从minio检查更新
///
Future<dynamic> _getUpdateUrlFromMinio(PackageInfo info) {
  return networkRepository!.checkUpdate(false).then((value) {
    if (value != null &&
        value[Platform.operatingSystem] != null &&
        value[Platform.operatingSystem]['version'] != null) {
      if (info.version != value['version']) {
        return Future.value(value);
      }
      return Future.value(''); //不更新
    }
    return Future.value(null); //检查更新失败
  });
}

/// 从github检查更新
///
Future<dynamic> _getUpdateUrlFromGithub(PackageInfo info) {
  return networkRepository!.checkUpdate(true).then((value) {
    if (value != null) {
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

      if (info.version != version[Platform.operatingSystem]!['version']) {
        return Future.value(version);
      }
      return Future.value(''); //不更新
    }
    return Future.value(null); //检查更新失败
  });
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
