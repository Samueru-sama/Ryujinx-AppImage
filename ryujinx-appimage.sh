#!/bin/sh

APP=ryujinx
SITE="Ryujinx/release-channel-master"

# Create folders
if [ -z "$APP" ]; then exit 1; fi
mkdir -p ./$APP/tmp && cd ./$APP/tmp

# DOWNLOAD THE ARCHIVE
version=$(wget -q https://api.github.com/repos/$SITE/releases -O - | grep browser_download_url | grep -i linux_x64.tar.gz | cut -d '"' -f 4 | head -1)
wget $version
echo "$version" >> ./version
tar fx ./*tar*
cd ..
mkdir ./$APP.AppDir
mv --backup=t ./tmp/*/* ./$APP.AppDir
rm -rf "./tmp"

cd ./$APP.AppDir

# DESKTOP ENTRY
echo "[Desktop Entry]
Version=1.0
Name=Ryujinx
Type=Application
Icon=Ryujinx
Exec=Ryujinx.sh %f
Comment=A Nintendo Switch Emulator
GenericName=Nintendo Switch Emulator
Terminal=false
Categories=Game;Emulator;
MimeType=application/x-nx-nca;application/x-nx-nro;application/x-nx-nso;application/x-nx-nsp;application/x-nx-xci;
Keywords=Switch;Nintendo;Emulator;
StartupWMClass=Ryujinx
PrefersNonDefaultGPU=true" >> ./$APP.desktop

# AppRun
cat >> ./AppRun << 'EOF'
#!/bin/sh
CURRENTDIR="$(readlink -f "$(dirname "$0")")"
exec "$CURRENTDIR"/Ryujinx.sh "$@"
EOF
chmod a+x ./AppRun

wget https://raw.githubusercontent.com/Ryujinx/Ryujinx/master/src/Ryujinx/Ryujinx.ico -O ./Ryujinx.png 2> /dev/null # Get Icon
ln -s ./Ryujinx.png ./.DirIcon

# MAKE APPIMAGE
cd ..
wget -q $(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | grep -v zsync | grep -i continuous | grep -i appimagetool | grep -i x86_64 | grep browser_download_url | cut -d '"' -f 4 | head -1) -O appimagetool
chmod a+x ./appimagetool

# Do the thing!
ARCH=x86_64 VERSION=$(./appimagetool -v | grep -o '[[:digit:]]*') ./appimagetool -s ./$APP.AppDir && 
ls ./*.AppImage || { echo "appimagetool failed to make the appimage"; exit 1; }

VERSION=$(echo $version | awk -F / '{print $(NF-1)}')
NAME=$(ls *AppImage)
mv ./*AppImage ./"$VERSION"-"$NAME"

# Clean up
if [ -z "$APP" ]; then exit 1; fi # Being extra safe lol
rm -rf "./$APP.AppDir"
rm ./appimagetool
mv ./*.AppImage ..
echo "All Done!"
