#!/bin/bash

set -e

## 处理更新信息
sed -i '4c     version: '"$1" pubspec.yaml


flutter_path="/opt/hostedtoolcache/flutter/stable-3.10.6-x64/.pub-cache/hosted/pub.dev"

# 兼容 flutter 3.10.6
test -d "/opt/hostedtoolcache/flutter/" && ( sed -i '39 d' "$flutter_path/connectivity_plus-4.0.1/android/build.gradle" &&   sed -i '27 d' "$flutter_path/connectivity_plus-4.0.1/android/build.gradle" &&   sed -i '49 d' "$flutter_path/audioplayers_android-3.0.2/android/build.gradle"  &&   sed -i '41 d' "$flutter_path/file_picker-5.3.3/android/build.gradle" &&  sed -i '31 d' "$flutter_path/package_info_plus-4.0.2/android/build.gradle" )

## linxu deb打包 ./deb.sh version
flutter build apk --split-per-abi --release -vv


