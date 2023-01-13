#!/bin/bash

## 由于ubuntu双系统windows权限始终为777，所以需要换到linux目录下做操作
  ## 处理更新信息
 sed -i '13c     "version": "'$1'",' version.json
 sed -i '15c     "file": "quiet/v'$1'quiet-android-'$1'.apk"' version.json
 sed -i '4c     version: '"$1" pubspec.yaml
if [ -f mc ]
then
#  外部的 alias 无法对 .sh 文件内生效。
  alias mc="`pwd`/mc"
fi

## linxu deb打包 ./deb.sh version
 flutter build apk && cp build/app/outputs/apk/release/app-v$1-release.apk quiet-android-v$1.apk && mc cp quiet-android-v$1.apk bc/temp/quiet/v$1 && mc cp quiet-android-v$1.apk bc/temp/quiet/quiet-android-latest.apk && mc cp build/app/outputs/apk/release/output-metadata.json bc/temp/quiet && mc cp version.json bc/temp


