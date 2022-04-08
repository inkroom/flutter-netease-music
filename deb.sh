## linxu deb打包
 flutter build linux
## 由于ubuntu双系统windows权限始终为777，所以需要换到linux目录下做操作
 cp -r linux/deb ~/

 mkdir -p  ~/deb/opt/quiet/
 cp -r build/linux/x64/release/bundle/* ~/deb/opt/quiet/
 chmod 755 -R ~/deb/DEBIAN/
## 更换版本号
 sed -i 's/_version_/'"$1"'/g' ~/deb/DEBIAN/control
  ## 处理更新信息
 sed '3c     "version": "'$1'",' version.json
 sed '5c     "file": "quiet-'$1'.deb",' version.json

 dpkg-deb -b ~/deb build/linux/x64/release/quiet-$1.deb &&  mc build/linux/x64/release/quiet-$1.deb bc/temp &&  mc version.json bc/temp
## 删除目录
 rm -rf ~/deb
