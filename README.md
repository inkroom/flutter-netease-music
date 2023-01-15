# Quiet

多源音乐播放器，基于 [https://github.com/inkroom/flutter-netease-music](https://github.com/inkroom/flutter-netease-music)，目前支持酷狗、网易云、酷我、咪咕

A Universal copy app of [NeteaseMusic](https://music.163.com/#/download)

## How to start (如何开始)

1. clone project to local

  ```bash
  git clone https://github.com/inkroom/flutter-netease-music.git 
  ```

2. install [Flutter](https://flutter.io/docs/get-started/install)

    * require latest flutter master channel.
    * 最新构建基于 3.3.10

3. build & run

 ```bash
 flutter run --profile
 ```

### Linux requirement.

**appindicator3-0.1**

debian:

   ```shell
   sudo apt -y  install vlc libvlc-dev libappindicator3-dev
   ```

如果是deepin还需要以下命令

```shell
# 用于打开文件选择框
sudo apt install -y zenity
```

## Dependency backend

* Toast and InApp notification：
  [**oktoast**](https://github.com/OpenFlutter/flutter_oktoast)
* music player(desktop):
  [**dart_vlc**](https://github.com/alexmercerind/dart_vlc)
* netease api service:
  [**NeteaseCloudMusicApi**](https://github.com/ziming1/NeteaseCloudMusicApi)

## 更新国际化

第一次需要执行

```shell
flutter pub global activate intl_utils
```

之后修改了 **lib/l10n/** 下的文件

```shell
flutter --no-color pub global run intl_utils:generate
```

## package

### windows

```shell
./w.bat 0.6.0
```

### linux

```shell
./deb.sh 0.6.0
```

### android

```shell
./a.bat 0.6.0
```

### github action

 注意：action会将**所有平台**一起构建

 构建成功或失败，将会通过 ntfy 通知

```shell

git tag v0.6.0 # 前缀 v 不能少
git push --tags

```

## Desktop Preview

| light                                                           | dark                                                           |
|-----------------------------------------------------------------|----------------------------------------------------------------|
| ![playlist](https://boyan01.github.io/quiet/playlist_light.png) | ![playlist](https://boyan01.github.io/quiet/playlist_dark.png) |
| ![playing](https://boyan01.github.io/quiet/playing_light.png)   | ![playing](https://boyan01.github.io/quiet/playing_dark.png)   |

## Mobile Platforms Preview

|   ![main_playlist](https://boyan01.github.io/quiet/main_playlist.png)   |    ![main_cloud](https://boyan01.github.io/quiet/main_playlist_dark.png)    | ![main_cloud](https://boyan01.github.io/quiet/main_cloud.jpg) | ![artist_detail](https://boyan01.github.io/quiet/artist_detail.jpg) |
|:-----------------------------------------------------------------------:|:---------------------------------------------------------------------------:|:-------------------------------------------------------------:|:-------------------------------------------------------------------:|
| ![playlist_detail](https://boyan01.github.io/quiet/playlist_detail.png) |                                                                             |    ![playing](https://boyan01.github.io/quiet/playing.png)    |        ![search](https://boyan01.github.io/quiet/search.jpg)        |
| ![music_selection](https://boyan01.github.io/quiet/music_selection.png) | ![playlist_selector](https://boyan01.github.io/quiet/playlist_selector.jpg) |                                                               |     ![每日推荐](https://boyan01.github.io/quiet/daily_playlist.png)     |
|     ![ios](https://boyan01.github.io/quiet/ios_playlist_detail.jpg)     |           ![ios](https://boyan01.github.io/quiet/user_detail.png)           |                                                               |                                                                     |

