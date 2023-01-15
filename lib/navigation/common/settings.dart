import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/providers/cloud_tracks_provider.dart';
import 'package:quiet/repository.dart';
import 'package:quiet/repository/setting.dart';
import 'dart:convert' as convert;
import '../../providers/navigator_provider.dart';
import '../../providers/settings_provider.dart';

class ThemeSwitchRadios extends ConsumerWidget {
  const ThemeSwitchRadios({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      settingStateProvider.select((value) => value.themeMode),
    );
    final notifier = ref.read(settingStateProvider.notifier);
    return Column(
      children: [
        RadioListTile<ThemeMode>(
          onChanged: (mode) => notifier.setThemeMode(mode!),
          groupValue: themeMode,
          value: ThemeMode.system,
          title: Text(context.strings.themeAuto),
        ),
        RadioListTile<ThemeMode>(
          onChanged: (mode) => notifier.setThemeMode(mode!),
          groupValue: themeMode,
          value: ThemeMode.light,
          title: Text(context.strings.themeLight),
        ),
        RadioListTile<ThemeMode>(
          onChanged: (mode) => notifier.setThemeMode(mode!),
          groupValue: themeMode,
          value: ThemeMode.dark,
          title: Text(context.strings.themeDark),
        )
      ],
    );
  }
}

class DebugPlatformNavigationRadios extends ConsumerWidget {
  const DebugPlatformNavigationRadios({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(debugNavigatorPlatformProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioListTile<NavigationPlatform>(
          onChanged: (mode) =>
          ref.read(debugNavigatorPlatformProvider.notifier).state = mode!,
          groupValue: platform,
          value: NavigationPlatform.desktop,
          title: Text(NavigationPlatform.desktop.name),
        ),
        RadioListTile<NavigationPlatform>(
          onChanged: (mode) =>
          ref.read(debugNavigatorPlatformProvider.notifier).state = mode!,
          groupValue: platform,
          value: NavigationPlatform.mobile,
          title: Text(NavigationPlatform.mobile.name),
        ),
      ],
    );
  }
}

// 启动播放设置项
class AutoPlayOnStart extends ConsumerWidget {
  const AutoPlayOnStart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckboxListTile(
      value: ref.watch(
        settingStateProvider.select((value) => value.autoPlayOnStart),
      ),
      onChanged: (value) => ref
          .read(settingStateProvider.notifier)
          .setAutoPlayOnStart(value: value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(context.strings.autoPlayOnStart),
    );
  }
}

class SkipAccompanimentCheckBox extends ConsumerWidget {
  const SkipAccompanimentCheckBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CheckboxListTile(
      value: ref.watch(
        settingStateProvider.select((value) => value.skipAccompaniment),
      ),
      onChanged: (value) => ref
          .read(settingStateProvider.notifier)
          .setSkipAccompaniment(skip: value ?? false),
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(context.strings.skipAccompaniment),
    );
  }
}

/// 切换网络设置
class NetworkSwitchRadios extends ConsumerWidget {
  const NetworkSwitchRadios({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkMode = ref.watch(
      settingStateProvider.select((value) => value.networkMode),
    );
    final notifier = ref.read(settingStateProvider.notifier);
    return Column(
      children: [
        RadioListTile<NetworkMode>(
          onChanged: (mode) => notifier.setNetworkMode(mode!),
          groupValue: networkMode,
          value: NetworkMode.WIFI,
          title: Text(context.strings.settingItemOnlyWIFI),
        ),
        RadioListTile<NetworkMode>(
          onChanged: (mode) => notifier.setNetworkMode(mode!),
          groupValue: networkMode,
          value: NetworkMode.MOBILE,
          title: Text(context.strings.settingItemOnlyMobile),
        ),
        RadioListTile<NetworkMode>(
          onChanged: (mode) => notifier.setNetworkMode(mode!),
          groupValue: networkMode,
          value: NetworkMode.NONE,
          title: Text(context.strings.settingItemNoNetwork),
        )
      ],
    );
  }
}

// 导入导出功能
class ImportAndExportSetting extends ConsumerWidget {
  const ImportAndExportSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        TextButton(
            onPressed: () {
              if (ref.read(settingStateProvider).importing) return;
              List<String>? allow;
              if (Platform.isWindows || Platform.isLinux) {
                allow = ["quiet"];
              }

              FilePicker.platform
                  .pickFiles(allowedExtensions: allow)
                  .then((value) {
                if (value != null &&
                    value.count == 1 &&
                    value.files[0].extension == 'quiet') {
                  ref.read(settingStateProvider.notifier).setImport(true);
                  final inputStream = InputFileStream(value.files[0].path!);
                  // Decode the zip from the InputFileStream. The archive will have the contents of the
                  // zip, without having stored the data in memory.
                  final archive = ZipDecoder().decodeBuffer(inputStream);

                  ArchiveFile? a = archive.findFile("list.txt");
                  if (a != null) {
                    String json = const Utf8Decoder().convert(a.content);

                    var d =
                        CloudTracksDetail.fromJson(convert.jsonDecode(json));

                    String savePath = ref.read(settingStateProvider).savePath;
                    // 处理文件链接，需要补上前缀
                    for (var track in d.tracks) {
                      if (track.file != null && track.file!.isNotEmpty) {
                        track.file = '$savePath/${track.file}';
                      }
                    }
                    debugPrint("读取的数据=${d.tracks.toString()}");
                  }
                  return value;
                }
              }).then((value) {
                ref.read(settingStateProvider.notifier).setImport(false);
                return value;
              }).catchError((error, s) {
                debugPrint('$error $s');
                debugPrint(error);

                ref.read(settingStateProvider.notifier).setImport(false);
              });
            },
            child: Text(
                ref.watch(settingStateProvider).importing
                    ? context.strings.settingImportIng
                    : context.strings.settingImport,
                style: Theme.of(context).textTheme.bodyText1)),
        TextButton(
            onPressed: () {
              if (ref.read(settingStateProvider).exporting) return;

              void export(saveDir) {
                ref.read(settingStateProvider.notifier).setExporting(true);
                // 获取当前的歌单数据
                CloudTracksDetailState state = ref.read(cloudTracksProvider);
                List<Track> tracks = state.tracks;

                Archive ar = Archive();
                List<Track> newTracks = [];
                for (var track in tracks) {
                  if (track.file != null && track.file!.isNotEmpty) {
                    ArchiveFile file = ArchiveFile(
                        "tracks/" +
                            track.file!
                                .substring(track.file!.lastIndexOf("/") + 1),
                        0,
                        InputFileStream(track.file!));
                    ar.addFile(file);
                    debugPrint(
                        '文件路径=${track.file} 文件名 ${track.file!.substring(track.file!.lastIndexOf("/") + 1)}');
                  }

                  // 处理文件路径
                  Track newTrack = Track.fromJson(track.toJson());
                  newTrack.file = newTrack.file
                      ?.substring(track.file!.lastIndexOf("/") + 1);
                  newTracks.add(newTrack);
                }

                var d = CloudTracksDetail(
                    tracks: newTracks,
                    size: state.size,
                    maxSize: state.maxSize,
                    trackCount: state.trackCount);
                String json = convert.jsonEncode(d.toJson());
                File file = File("$saveDir/${Random().nextDouble()}");
                file.writeAsString(json, flush: true).then((value) {
                  debugPrint(file.absolute.path);
                  // 把歌单写进去
                  ar.addFile(ArchiveFile(
                      "list.txt", 0, InputFileStream(file.absolute.path)));

                  debugPrint("list: $json");
                  // 输出
                  ZipEncoder().encode(ar,
                      output: OutputFileStream("$saveDir/export.quiet"));

                  file.delete();
                  debugPrint("输出完成");
                  ref.read(settingStateProvider.notifier).setExporting(false);
                });
              }

              Future f = Future.value(true);

              if (Platform.isAndroid) {
                f.then((value) {
                  debugPrint(
                      "请求"); // TODO 2023/1/15 同时请求两个权限，app会崩溃。已经有人提了pr，等三方库更新
                  return Permission.manageExternalStorage.request();
                }).then((element) {
                  debugPrint("结果=${element}");
                  return element.isGranted;
                });
              }
              f.then((value) {
                if (value == true) {
                  return FilePicker.platform.getDirectoryPath().then((saveDir) {
                    if (saveDir != null && saveDir.isNotEmpty) {
                      export(saveDir);
                    }
                    return saveDir;
                  });
                }
                return value;
              });
              f.catchError((error) {
                debugPrint(error);
                ref.read(settingStateProvider.notifier).setExporting(false);
              });
            },
            child: Text(
              ref.watch(settingStateProvider).exporting
                  ? context.strings.settingExportIng
                  : context.strings.settingExport,
              style: Theme.of(context).textTheme.bodyText1,
            ))
      ],
    );
  }
}
