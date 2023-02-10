import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiet/component.dart';
import 'package:quiet/material.dart';
import 'package:quiet/navigation/common/update_dialog.dart';
import 'package:quiet/providers/settings_provider.dart';

import '../../common/settings.dart';

class PageSettings extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            title: context.strings.settingNetwork,
            children: const [NetworkSwitchRadios()],
          ),
          SettingGroup(
            title: context.strings.play,
            children: const [AutoPlayOnStart()],
          ),
          const Divider(height: 20),
          SettingGroup(
            title: context.strings.settingPlayFlagTitle,
            children: const [PlayListFlag()],
          ),
          const Divider(height: 20),
          if (!kReleaseMode) const _DebugNavigationPlatformSetting(),
          if (!kReleaseMode) const Divider(height: 20),
          const ImportAndExportSetting(),
          // if (Platform.isAndroid)
          SettingGroup(
            children: [
              ListTile(
                title: Text(context.strings.checkUpdate),
                onTap: () {
                  updateApp(context, onCheckVersion: ((shouldUpdate) {
                    if (!shouldUpdate) {
                      toast(context.strings.newestVersion);
                    }
                  }));
                },
              )
            ],
          ),
          SettingGroup(
            children: [
              ListTile(
                title: Text(context.strings.about),
                onTap: () {
                  final info = ref.read(versionStateProvider).info;
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AboutDialog(
                          applicationIcon: Image.asset(
                            "assets/logo.png",
                            width: 50,
                            height: 50,
                          ),
                          applicationVersion: info?.version,
                          applicationLegalese:
                              context.strings.applicationLegalese,
                        );
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
