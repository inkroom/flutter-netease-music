import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quiet/component.dart';
import 'package:quiet/providers/settings_provider.dart';
import 'package:quiet/repository.dart';
import 'package:update_app/update_app.dart';

import '../../common/settings.dart';

class PageSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.strings.settings),
        titleSpacing: 0,
      ),
      body: ListView(
        children: <Widget>[
          SettingGroup(
            title: context.strings.theme,
            children: const [ThemeSwitchRadios()],
          ),
          const Divider(height: 20),
          SettingGroup(
            title: context.strings.settingItemNoNetwork,
            children: const [NetworkSwitchRadios()],
          ),
          const Divider(height: 20),
          if (!kReleaseMode) const _DebugNavigationPlatformSetting(),
          if (!kReleaseMode) const Divider(height: 20),
          if (Platform.isAndroid)
            SettingGroup(
              children: [
                ListTile(
                  title: Text(context.strings.checkUpdate),
                  onTap: () {
                    /// 当前只支持android平台自动更新
                    if (NetworkSingleton.instance.allowNetwork()) {
                      networkRepository?.checkUpdate().then((value) {
                        if (value != null && value['versionName'] != null) {
                          PackageInfo.fromPlatform().then((info) {
                            if (info.version != value['versionName']) {
                              toast(context.strings
                                  .updateTip(value['versionName']));
                              return UpdateApp.updateApp(
                                  url:
                                      "http://minio.bcyunqian.com/temp/${value['outputFile']}",
                                  appleId: "375380948",
                                  title:
                                      context.strings.updateTitle(info.appName),
                                  description: context.strings
                                      .updateTip(value['versionName']));
                            } else {
                              toast(context.strings.newestVersion);
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
                  },
                )
              ],
            ),
          SettingGroup(
            children: [
              ListTile(
                title: Text(context.strings.about),
                onTap: () {
                  PackageInfo.fromPlatform().then((value) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AboutDialog(
                            applicationIcon: Image.asset(
                              "assets/logo.png",
                              width: 50,
                              height: 50,
                            ),
                            applicationVersion: value.version,
                            applicationLegalese:
                                context.strings.applicationLegalese,
                          );
                        });
                  });
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

class SettingGroup extends StatelessWidget {
  const SettingGroup({Key? key, this.title, required this.children})
      : super(key: key);

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null) _SettingTitle(title: title!),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          )
        ],
      ),
    );
  }
}

class _SettingTitle extends StatelessWidget {
  const _SettingTitle({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, top: 6, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(color: Color.fromARGB(255, 175, 175, 175)),
      ),
    );
  }
}

class _DebugNavigationPlatformSetting extends StatelessWidget {
  const _DebugNavigationPlatformSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Divider(height: 20),
        SettingGroup(
          title: 'Navigation Platform (Developer options)',
          children: [
            DebugPlatformNavigationRadios(),
          ],
        ),
      ],
    );
  }
}
