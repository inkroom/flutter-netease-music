## linxu deb打包

## 更换版本号
 sed -i 's/_version_/'"$1"'/g' linux/deb/DEBIAN/control
 
 flutter build linux

## 由于ubuntu双系统windows权限始终为777，所以需要换到linux目录下做操作
 cp -r linux/deb ~/

 mkdir -p  ~/deb/opt/quiet/

 cp -r build/linux/x64/release/bundle/* ~/deb/opt/quiet/
 
 chmod 755 -R ~/deb/DEBIAN/

 sed -i 's/_version_/'"$1"'/g' ~/deb/DEBIAN/control

 dpkg-deb -b ~/deb build/linux/x64/release/quiet-$1.deb

## 删除目录

 rm -rf ~/deb
