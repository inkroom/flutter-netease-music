## linxu deb打包

 flutter build linux

## 由于ubuntu双系统windows权限始终为777，所以需要换到linux目录下做操作
 cp -r linux/deb ~/

 mkdir -p  ~/deb/opt/quiet/

 cp -r build/linux/x64/release/bundle/* ~/deb/opt/quiet/
 
 chmod 755 -R ~/deb/DEBIAN/

## 更换版本号
 sed -i 's/_version_/'"$1"'/g' ~/deb/DEBIAN/control

## 更换文件大小
 size=$(du build/linux/x64/release/bundle -d 0 | tr -d "   build/linux/x64/release/bundle")
 sed -i 's/_size_/'"$size"'/g' ~/deb/DEBIAN/control



 dpkg-deb -b ~/deb build/linux/x64/release/quiet-$1.deb

## 删除目录

 rm -rf ~/deb
