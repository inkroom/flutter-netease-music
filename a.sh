#!/bin/bash

sed -i '4c version: '$1'' pubspec.yaml
## 处理更新信息
sed -i '15c     "version": "'$1'",' version.json
sed -i '4c     version: '"$1" pubspec.yaml

if [ test -d "/opt/hostedtoolcache/flutter/" ];
then
  # 处理 不兼容 3.10.5
  sed '39 d' "/opt/hostedtoolcache/flutter/stable-3.10.5-x64/.pub-cache/hosted/pub.dev/connectivity_plus-4.0.1/android/build.gradle"
  sed '27 d' "/opt/hostedtoolcache/flutter/stable-3.10.5-x64/.pub-cache/hosted/pub.dev/connectivity_plus-4.0.1/android/build.gradle"

  sed '49 d' "/opt/hostedtoolcache/flutter/stable-3.10.5-x64/.pub-cache/hosted/pub.dev/audioplayers_android-3.0.2/android/build.gradle"

  sed '41 d' "/opt/hostedtoolcache/flutter/stable-3.10.5-x64/.pub-cache/hosted/pub.dev/file_picker-5.3.2/android/build.gradle"
  sed '31 d' "/opt/hostedtoolcache/flutter/stable-3.10.5-x64/.pub-cache/hosted/pub.dev/package_info_plus-4.0.2/android/build.gradle"
fi


## linxu deb打包 ./deb.sh version
flutter build apk --split-per-abi --release


