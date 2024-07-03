#!/bin/sh
set -u
APP=ryujinx
SITE="Ryujinx/release-channel-master"

# CREATE DIRECTORIES
[ -n "$APP" ] && mkdir -p "./$APP/tmp" && cd "./$APP/tmp" || exit 1

# DOWNLOAD AND EXTRACT THE ARCHIVE
version=$(wget -q https://api.github.com/repos/$SITE/releases -O - | sed 's/[()",{} ]/\n/g' | grep -oi "https.*linux.*x64.*gz$" | head -1)
wget "$version" && tar fx ./*tar* || exit 1
cd ..
mkdir -p "./$APP.AppDir/usr/bin"
mv ./tmp/*/* "./$APP.AppDir/usr/bin"
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
APPIMAGETOOL=$(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | sed 's/[()",{} ]/\n/g' | grep -oi 'https.*continuous.*tool.*86_64.*mage$')
wget -q "$APPIMAGETOOL" -O ./appimagetool
chmod a+x ./appimagetool

# Do the thing!
ARCH=x86_64 
VERSION="$(echo "$version" | awk -F"/" '{print $(NF-1)}')" ./appimagetool -s ./"$APP".AppDir
[ -n "$APP" ] && mv ./*.AppImage .. && cd .. && rm -rf ./"$APP" || exit 1
echo "All Done!"
