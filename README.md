# Quiet

多源音乐播放器，基于 [https://github.com/boyan01/flutter-netease-music](https://github.com/boyan01/flutter-netease-music)
，目前支持酷狗、网易云、酷我、咪咕

A Universal copy app of [NeteaseMusic](https://music.163.com/#/download)

## How to start (如何开始)

1. clone project to local

  ```bash
  git clone https://github.com/inkroom/flutter-netease-music.git 
  ```

2. install [Flutter](https://flutter.io/docs/get-started/install)

    * require latest flutter master channel.
    * 最新构建基于 3.10.5

3. build & run

 ```bash
 flutter run --profile
 ```

### Linux requirement.

- **appindicator3-0.1**
- **gstreamer**


   ```shell
   sudo apt -y  install appindicator3-0.1 libappindicaor3-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev 
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
  [**audioplayers**](https://github.com/bluefireteam/audioplayers)
* netease api service:
  [**NeteaseCloudMusicApi**](https://github.com/ziming1/NeteaseCloudMusicApi)

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

修改 pubspec.yaml 的版本号

```shell

git push origin master

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

## FAQ

#### 1. deepin无法自定义存储路径

```shell
# 用于打开文件选择框
sudo apt install -y zenity
```

#### 2. ~~修改pubspec.yaml后，windows的版本号没有变~~

>
> 这是flutter早期模板的[bug](https://github.com/flutter/flutter/issues/73652)
> 需要修改 **windows/runner/Runner.rc** 的第66行和第72行
>

#### 3. 修改了实体

```shell
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### 4. 修改了国际化文件

第一次需要执行

```shell
flutter pub global activate intl_utils
```

之后修改了 **lib/l10n/** 下的文件

```shell
flutter --no-color pub global run intl_utils:generate
```


#### 5. 引入的组件在linux平台有依赖

首先在现有基础上打出 deb 包，然后进行解包，执行命令获取依赖，最后将输出的结果重新填入 **linux/deb/DEBIAN/control**的**depend**

大致命令如下

```shell
sh deb.sh 0.9.3
dpkg-deb -R build/linux/x64/release/quiet-linux-v0.9.3.deb ./tmp
cd ./tmp
mv DEBIAN debian
dpkg-shlibdeps -O ./opt/quiet/quiet 
```

最终输出应该形式如下：

> shlibs:Depends=libatk1.0-0 (>= 1.12.4), libc6 (>= 2.14), libcairo-gobject2 (>= 1.10.0),
> libcairo2 (>= 1.2.4), libgcc1 (>= 1:3.0), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.37.3),
> libgtk-3-0 (>= 3.9.12), libpango-1.0-0 (>= 1.14.0), libpangocairo-1.0-0 (>= 1.14.0), libstdc++6 (>=
> 5.2)

只需要把**Depends=**后面的内容复制到**linux/deb/DEBIAN/control**里即可

#### 6. android构建失败

如果出现类似以下错误

```
 Could not find method disable() for arguments [InvalidPackage] on task ':audioplayers_android:lint' of type com.android.build.gradle.tasks.LintGlobalTask.
```

这是 gradle 不兼容问题，目前找不到能够兼容的 gradle 版本，只能修改出现这个错误的依赖的 gradle 配置

去掉相应配置即可，具体修改逻辑可在 /a.sh 中看到，

涉及的第三方依赖为

- audioplayers
- file_picker
- package_info_plus

目前上述依赖版本已锁死，如需升级，需要修改相应脚本

#### 7. Nuget.exe

如果执行 `flutter build windows -v` 中出现 `Nuget.exe not found, trying to download or use cached version`

下载 [NuGet.exe](https://dist.nuget.org/win-x86-commandline/latest/nuget.exe) 放到 PATH 路径下
