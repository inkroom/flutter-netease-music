#!/bin/bash

sed -i '4c     version: '"$1" pubspec.yaml

## linxu deb打包 ./deb.sh version
 flutter build linux --release || exit 1
## 由于ubuntu双系统windows权限始终为777，所以需要换到linux目录下做操作
 cp -r linux/deb ~/

 mkdir -p  ~/deb/opt/quiet/
 cp -r build/linux/x64/release/bundle/* ~/deb/opt/quiet/
 chmod 755 -R ~/deb/DEBIAN/
## 更换版本号

 sed -i 's/_version_/'"$1"'/g' ~/deb/DEBIAN/control
  ## 处理更新信息
 sed -i '3c     "version": "'$1'",' version.json
  size=$(du ~/deb/opt/quiet/ --max-depth=0 | tr -cd "[0-9]")
  sed -i 's/_size_/'"$size"'/g' ~/deb/DEBIAN/control


 dpkg-deb -b ~/deb build/linux/x64/release/quiet-linux-v$1.deb
## 删除目录
rm -rf ~/deb
