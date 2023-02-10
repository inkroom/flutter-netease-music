import 'dart:convert';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quiet/extension.dart';
import 'package:quiet/material.dart';
import 'package:quiet/providers/cloud_tracks_provider.dart';
import 'package:quiet/repository.dart';
import 'package:quiet/repository/database.dart';
import 'package:quiet/repository/setting.dart';

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

/// 播放本地音乐时的标记
class PlayListFlag extends ConsumerWidget {
  const PlayListFlag({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint(
        "播放设置 ${ref.watch(settingStateProvider.select((value) => value.playFlag))}");
    return Row(
      children: TrackFlag.values
          .map((e) => Checkbox(
              value: ref.watch(settingStateProvider
                          .select((value) => value.playFlag)) &
                      e.bit ==
                  e.bit,
              activeColor: e.color,
              side: BorderSide(color: e.color),
              onChanged: (bool? value) {
                if (value == true) {
                  ref.read(settingStateProvider.notifier).setPlayFlag(
                      value: ref.read(settingStateProvider).playFlag | e.bit);
                } else {
                  ref.read(settingStateProvider.notifier).setPlayFlag(
                      value: (ref.read(settingStateProvider).playFlag | e.bit) ^
                          e.bit);
                }
              }))
          .toList(),
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

  static const String _listName = "list.txt";
  static const String _exportFileName = "export.quiet";
  static const String _trackDir = "tracks";
  static const String _lyricDir = "lyric";

  static void _zipOnIsolate(List<dynamic> params) async {
    debugPrint("异步 $params");
    String lyricDir = params[3] as String;
    Archive ar = Archive();
    for (var track in params[1]) {
      if (track.file != null && track.file!.isNotEmpty) {
        ArchiveFile file = ArchiveFile(
            "$_trackDir/" +
                track.file!.substring(track.file!.lastIndexOf(separator) + 1),
            0,
            InputFileStream(track.file!));
        ar.addFile(file);
        // debugPrint(
        //     '文件路径=${track.file} 文件名 ${track.file!.substring(track.file!.lastIndexOf("/") + 1)}');
      }
      // 添加歌词
      // 导出歌词时是按照当前的歌单来查询歌词缓存，可能存在已经移除的歌曲的歌词缓存不会被导入
      try {
        File file =
            File(lyricDir + separator + track.id.toString() + track.extra);
        debugPrint("歌词文件 = ${file.path}");
        if (file.existsSync()) {
          ar.addFile(ArchiveFile(
              "$_lyricDir/${track.id}", 0, InputFileStream(file.path)));
        }
        // debugPrint("歌词1 ${net == null}  $track ");
        // String? lyric = await net!.lyric(track, onlyCache: true);
        // if (lyric != null) {
        //   debugPrint("歌词 $lyric");
        //   ar.addFile(
        //       ArchiveFile("$_lyricDir/${track.id}", 0, utf8.encode(lyric)));
        // } else {
        //   debugPrint("没有歌词 $track");
        // }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    String list = params[2];
    ar.addFile(ArchiveFile(_listName, 0, utf8.encode(list)));

    // 异步，避免锁死 ui
    ZipEncoder()
        .encode(ar, output: OutputFileStream("${params[0]}/$_exportFileName"));
  }

  static Future<CloudTracksDetail> _unzipOnIsolate(List<dynamic> params) {
    String zipPath = params[0];
    String savePath = params[1];
    String lyricDir = params[2];
    final inputStream = InputFileStream(zipPath);
    // Decode the zip from the InputFileStream. The archive will have the contents of the
    // zip, without having stored the data in memory.
    final archive = ZipDecoder().decodeBuffer(inputStream);

    ArchiveFile? a = archive.findFile(_listName);
    if (a != null) {
      String json = const Utf8Decoder().convert(a.content);

      var d = CloudTracksDetail.fromJson(convert.jsonDecode(json));

      // 处理文件链接，需要补上前缀
      for (var track in d.tracks) {
        if (track.file != null && track.file!.isNotEmpty) {
          track.file = '$savePath$separator${track.file}';
        }
      }

      // 拷贝文件
      for (var element in archive.files) {
        if (element.isFile &&
            element.name != _listName &&
            element.name.startsWith(_trackDir)) {
          final outputStream = OutputFileStream(
              '$savePath$separator${element.name.replaceFirst(_trackDir + '/', '')}');
          // The writeContent method will decompress the file content directly to disk without
          // storing the decompressed data in memory.
          element.writeContent(outputStream);
          // Make sure to close the output stream so the File is closed.
          outputStream.close();
        } else if (element.isFile &&
            element.name != _listName &&
            element.name.startsWith(_lyricDir)) {
          final outputStream = OutputFileStream(
              '$lyricDir$separator${element.name.replaceFirst(_lyricDir + '/', '')}');
          // The writeContent method will decompress the file content directly to disk without
          // storing the decompressed data in memory.
          element.writeContent(outputStream);
          // Make sure to close the output stream so the File is closed.
          outputStream.close();
        }
      }
      debugPrint("读取的数据=${d.tracks.toString()}");

      return Future.value(d);
    }
    return Future.error(false);
  }

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

              Future f = Future.value(true);
              if (Platform.isAndroid) {
                f = f
                    .then((value) => Permission.storage.request())
                    .then((value) => value.isGranted);
              }
              f.then((value) {
                if (value == true) {
                  return FilePicker.platform
                      .pickFiles(
                          allowedExtensions: allow,
                          onFileLoading: (FilePickerStatus status) {
                            ref
                                .read(settingStateProvider.notifier)
                                .setImport(true);
                          })
                      .then((FilePickerResult? value) => (value != null &&
                              value.count == 1 &&
                              value.files.single.extension == "quiet")
                          ? value.files.single.path
                          : null);
                }
                return null;
              }).then((exportPath) async {
                if (exportPath != null) {
                  ref.read(settingStateProvider.notifier).setImport(true);

                  debugPrint("选择的文件路径  =${exportPath}  ");

                  CloudTracksDetail c = await compute(_unzipOnIsolate, [
                    exportPath,
                    ref.read(settingStateProvider).savePath,
                    await getLyricDirectory()
                  ]);
                  for (var element in c.tracks) {
                    ref.read(cloudTracksProvider.notifier).add(element);
                  }
                  debugPrint("结果= $c");
                  return exportPath;
                }
                return null;
              }).then((value) {
                ref.read(settingStateProvider.notifier).setImport(false);
                if (value != null) toast(context.strings.imported);
                return value;
              }).catchError((error, s) {
                debugPrint('$error $s');
                toast(context.strings.importFail);
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

              Future<String> export(String saveDir) {
                ref.read(settingStateProvider.notifier).setExporting(true);
                // 获取当前的歌单数据
                CloudTracksDetailState state = ref.read(cloudTracksProvider);
                List<Track> tracks = state.tracks;

                List<Track> newTracks = [];
                for (var track in tracks) {
                  // 处理文件路径
                  Track newTrack = Track.fromJson(track.toJson());
                  newTrack.file = newTrack.file
                      ?.substring(track.file!.lastIndexOf(separator) + 1);
                  newTracks.add(newTrack);
                }

                var d = CloudTracksDetail(
                    tracks: newTracks,
                    size: state.size,
                    maxSize: state.maxSize,
                    trackCount: state.trackCount);
                String json = convert.jsonEncode(d.toJson());
                return Future(() async {
                  debugPrint("开始打包");
                  return compute(_zipOnIsolate, [
                    saveDir,
                    tracks,
                    json,
                    await getLyricDirectory()
                  ]); // 因为不能直接传递 Archive 参数，只能放到异步任务里去 构建
                }).then((value) => saveDir).then((value) {
                  debugPrint("输出完成");
                  ref.read(settingStateProvider.notifier).setExporting(false);
                  toast(context.strings.exported);
                  return value;
                }).catchError((error, s) {
                  debugPrint("zip $error $s");
                  toast(context.strings.exportFail);
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
                      return export(saveDir);
                    }
                    return saveDir;
                  });
                }
                return value;
              });
              f.catchError((error) {
                debugPrint(error);
                ref.read(settingStateProvider.notifier).setExporting(false);
                toast(context.strings.exportFail);
                return error;
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

// void _zip(SendPort initialReplyTo) async {
//   //子Isolate对应的ReceivePort对象
//   final port = ReceivePort();
//   initialReplyTo.send(port.sendPort); // 给 父  isolate 一个通信渠道
//
//   port.listen((message) {
//     // 父 isolate 之后发送一次数据，所以肯定是压缩操作
//     if (message is List) {
//       Archive ar = message[0];
//       String saveDir = message[1];
//       ZipEncoder()
//           .encode(ar, output: OutputFileStream("$saveDir/export.quiet"));
//       initialReplyTo.send(true);
//     }
//   });
// }
