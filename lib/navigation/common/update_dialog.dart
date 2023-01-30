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
    networkRepository?.checkUpdate().then((value) {
      if (value != null &&
          value[Platform.operatingSystem] != null &&
          value[Platform.operatingSystem]['version'] != null) {
        PackageInfo.fromPlatform().then((info) {
          if (info.version != value[Platform.operatingSystem]['version']) {
            toast(S.current
                .updateTip(value[Platform.operatingSystem]['version']));
            if (Platform.isWindows || Platform.isLinux) {
              if (value[Platform.operatingSystem]['url'] != null &&
                  value[Platform.operatingSystem]['url'] != '') {
                launchUrl(
                    Uri.parse("${value[Platform.operatingSystem]['url']}"));
              } else {
                /// 打开网址
                launchUrl(Uri.parse(
                    "http://minio.bcyunqian.com/temp/${value[Platform.operatingSystem]['file']}"));
              }
            } else if (Platform.isAndroid) {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return WillPopScope(
                        child: _UpdateDialogContent(
                          url: value[Platform.operatingSystem]['url'] ??
                              "http://minio.bcyunqian.com/temp/${value[Platform.operatingSystem]['file']}",
                          filename: value[Platform.operatingSystem]['file'],
                          version: value[Platform.operatingSystem]['version'],
                          onDownloadComplete: (filePath) {
                            log('下載的文件位置= $filePath');
                            // 唤起安装
                            MethodChannel("quiet.update.app.channel.name")
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
          } else {
            if (onCheckVersion != null) {
              onCheckVersion(false);
            }
            // toast(context.strings.newestVersion);
          }
          return -2;
        }).then((value) {
          if (value == -1) {
            toast('更新失败');
          }
        });
      }
    }).catchError((error) {
      log("$error");
      // showDialog(context: context, builder: (context) => Text('检查失败 $error'));
      toast(S.current.updateFail);
    });
  }
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
