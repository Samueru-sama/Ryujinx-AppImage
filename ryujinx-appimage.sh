#!/bin/sh

APP=ryujinx
SITE="Ryujinx/release-channel-master"

# CREATE DIRECTORIES
if [ -z "$APP" ]; then exit 1; fi
mkdir -p "./$APP/tmp" && cd "./$APP/tmp"

# DOWNLOAD AND EXTRACT THE ARCHIVE
version=$(wget -q https://api.github.com/repos/$SITE/releases -O - | grep browser_download_url | grep -i linux_x64.tar.gz | cut -d '"' -f 4 | head -1)
wget "$version"
tar fx ./*tar* || exit 1
cd ..
mkdir -p "./$APP.AppDir/usr/bin"
mv --backup=t ./tmp/*/* "./$APP.AppDir/usr/bin"
cd "./$APP.AppDir" || exit 1

# DESKTOP ENTRY AND ICON
DESKTOP="https://raw.githubusercontent.com/Ryujinx/Ryujinx/master/distribution/linux/Ryujinx.desktop"
ICON="https://raw.githubusercontent.com/Ryujinx/Ryujinx/master/src/Ryujinx/Ryujinx.ico -O ./Ryujinx.png"
wget $DESKTOP -O ./$APP.desktop && wget $ICON -O ./Ryujinx.png && ln -s ./Ryujinx.png ./.DirIcon

# AppRun
cat >> ./AppRun << 'EOF'
#!/bin/sh
CURRENTDIR="$(readlink -f "$(dirname "$0")")"
exec "$CURRENTDIR"/usr/bin/Ryujinx.sh "$@"
EOF
chmod a+x ./AppRun

# MAKE APPIMAGE
cd ..
APPIMAGETOOL=$(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | grep -v zsync | grep -i continuous | grep -i appimagetool | grep -i x86_64 | grep browser_download_url | cut -d '"' -f 4 | head -1)
wget -q "$APPIMAGETOOL" -O ./appimagetool
chmod a+x ./appimagetool

# Do the thing!
ARCH=x86_64 VERSION=$(./appimagetool -v | grep -o '[[:digit:]]*') ./appimagetool -s ./$APP.AppDir && 
ls ./*.AppImage || { echo "appimagetool failed to make the appimage"; exit 1; }

APPVERSION=$(echo $version | awk -F / '{print $(NF-1)}')
APPNAME=$(ls *AppImage)
mv ./*AppImage ./"$APPVERSION"-"$APPNAME"
if [ -z "$APP" ]; then exit 1; fi # Being extra safe lol
mv ./*.AppImage .. && cd .. && rm -rf "./$APP"
echo "All Done!"
