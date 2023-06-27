#!/bin/bash

sed -i '4c     version: '"$1" pubspec.yaml

## linxu deb打包 ./deb.sh version
flutter build linux --release || exit 1
## 由于ubuntu双系统windows权限始终为777，所以需要换到linux目录下做操作
cp -r linux/deb ~/

mkdir -p  ~/deb/opt/quiet/
cp -r build/linux/x64/release/bundle/* ~/deb/opt/quiet/
chmod 755 -R ~/deb/DEBIAN/

test -f ~/deb/opt/quiet/quiet || ( echo "构建失败，没有可执行文件" && exit 1  )

size=$(du ~/deb/opt/quiet/ --max-depth=0 | tr -cd "[0-9]")
export QUIET_VERSION=$1
export QUIET_SIZE=$size
env
echo "替换"
cat ~/deb/DEBIAN/control
echo "ing"
home_dir=$(pwd)
## 更换版本号
cd ~/deb/DEBIAN/
(cat control | envsubst) > control2
cat control2
echo "替换完成"
# 原文件输出会出问题，但是换个文件就正常了 不知道为什么
rm -f control
mv control2 control
cat control

cd $home_dir
dpkg-deb -b ~/deb build/linux/x64/release/quiet-linux-v$1.deb || exit 1
## 删除目录
rm -rf ~/deb
