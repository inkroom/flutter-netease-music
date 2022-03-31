import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quiet/providers/settings_provider.dart';
import 'package:quiet/repository/database.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/repository/netease.dart';

// 软件更新dialog

/// [path] 文件位置，可以拿来安装
typedef OnDownloadComplete = void Function(String path);
typedef OnCheckVersion = void Function(bool shouldUpdate);

void updateApp(BuildContext context, {OnCheckVersion? onCheckVersion}) {
  /// 当前只支持android平台自动更新
  if (NetworkSingleton.instance.allowNetwork()) {
    networkRepository?.checkUpdate().then((value) {
      if (value != null && value['versionName'] != null) {
        PackageInfo.fromPlatform().then((info) {
          if (info.version != value['versionName']) {
            toast(context.strings.updateTip(value['versionName']));

            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return _UpdateDialogContent(
                    url:
                        "http://minio.bcyunqian.com/temp/${value['outputFile']}",
                    filename: value['outputFile'],
                    version: value['versionName'],
                    onDownloadComplete: (filePath) {
                      log('下載的文件位置= $filePath');
                      // 唤起安装
                      MethodChannel("quiet.update.app.channel.name")
                          .invokeMethod("installApk", {"path": filePath});

                      // 关闭弹窗
                      Navigator.pop(context, "");
                    },
                  );
                }).then((value) {
              log("dialog $value");
            }).catchError((error, s) {
              log("dialog $error $s");
            });
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
      // showDialog(context: context, builder: (context) => Text('检查失败 $error'));
      toast('检查失败 $error');
    });
  } else {
    toast(context.strings.networkNotAllow);
  }
}

class _UpdateDialogContent extends StatefulWidget {
  const _UpdateDialogContent(
      {Key? key,
      required this.url,
      required this.filename,
      required this.version,
      required this.onDownloadComplete})
      : super(key: key);

  final String url;
  final OnDownloadComplete onDownloadComplete;
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
  _UpdateDialogState createState() => _UpdateDialogState(
      url: url,
      filename: filename,
      version: version,
      onDownloadComplete: onDownloadComplete);
}

class _UpdateDialogState extends State<_UpdateDialogContent> {
  _UpdateDialogState(
      {required this.url,
      required this.filename,
      required this.version,
      required this.onDownloadComplete});

  double _processValue = 0;

  String url;
  String filename;
  String version;

  OnDownloadComplete onDownloadComplete;

  @override
  void initState() {
    getApkDirectory().then((value) {
      Dio().download(url, "$value/$filename",
          onReceiveProgress: (int count, int total) {
        setState(() {
          _processValue = count / total;
          if (_processValue >= 1) {
            onDownloadComplete("$value/$filename");
          }
        });
      });
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
          context.strings.updateTip(version),
          style: context.textTheme.bodyMedium,
        )
      ],
    );
  }
}
