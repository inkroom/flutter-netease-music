#!/bin/bash

sed -i '4c     version: '"$1" pubspec.yaml

## linxu deb打包 ./deb.sh version
 flutter build linux --release
## 由于ubuntu双系统windows权限始终为777，所以需要换到linux目录下做操作
 cp -r linux/deb ~/

 mkdir -p  ~/deb/opt/quiet/
 cp -r build/linux/x64/release/bundle/* ~/deb/opt/quiet/
 chmod 755 -R ~/deb/DEBIAN/
## 更换版本号

 sed -i 's/_version_/'"$1"'/g' ~/deb/DEBIAN/control
  ## 处理更新信息
 sed -i '3c     "version": "'$1'",' version.json
 sed -i '5c     "file": "quiet/v'$1'quiet-linux-v'$1'.deb"' version.json
  size=$(du ~/deb/opt/quiet/ --max-depth=0 | tr -cd "[0-9]")
  sed -i 's/_size_/'"$size"'/g' ~/deb/DEBIAN/control

if [ -f mc ]
then
#  外部的 alias 无法对 .sh 文件内生效。
  alias mc="`pwd`/mc"
fi

 dpkg-deb -b ~/deb build/linux/x64/release/quiet-linux-v$1.deb &&  mc cp build/linux/x64/release/quiet-linux-v$1.deb bc/temp/quiet/v$1/quiet-linux-v$1.deb && mc cp build/linux/x64/release/quiet-linux-v$1.deb bc/temp/quiet/quiet-linux-latest.deb &&  mc cp version.json bc/temp && mc cp version.json bc/temp/quiet
## 删除目录
 # rm -rf ~/deb
