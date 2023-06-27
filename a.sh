#!/bin/bash

## 处理更新信息
sed -i '4c     version: '"$1" pubspec.yaml


# 兼容 flutter 3.10.5
test -d "/opt/hostedtoolcache/flutter/" && ( sed -i '39 d' "/opt/hostedtoolcache/flutter/stable-3.10.5-x64/.pub-cache/hosted/pub.dev/connectivity_plus-4.0.1/android/build.gradle" &&   sed -i '27 d' "/opt/hostedtoolcache/flutter/stable-3.10.5-x64/.pub-cache/hosted/pub.dev/connectivity_plus-4.0.1/android/build.gradle" &&   sed -i '49 d' "/opt/hostedtoolcache/flutter/stable-3.10.5-x64/.pub-cache/hosted/pub.dev/audioplayers_android-3.0.2/android/build.gradle" &&   sed -i '41 d' "/opt/hostedtoolcache/flutter/stable-3.10.5-x64/.pub-cache/hosted/pub.dev/file_picker-5.3.2/android/build.gradle" &&  sed -i '31 d' "/opt/hostedtoolcache/flutter/stable-3.10.5-x64/.pub-cache/hosted/pub.dev/package_info_plus-4.0.2/android/build.gradle" )

## linxu deb打包 ./deb.sh version
flutter build apk --split-per-abi --release -vv


