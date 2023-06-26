#!/bin/bash

sed -i '4c version: '$1'' pubspec.yaml
## 处理更新信息
sed -i '15c     "version": "'$1'",' version.json
sed -i '4c     version: '"$1" pubspec.yaml

## linxu deb打包 ./deb.sh version
flutter build apk --split-per-abi --release


