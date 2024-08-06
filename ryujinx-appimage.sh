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
ICON="https://raw.githubusercontent.com/Ryujinx/Ryujinx/master/src/Ryujinx/Ryujinx.ico"
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
APPIMAGETOOL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"
wget -q "$APPIMAGETOOL" -O ./appimagetool
chmod a+x ./appimagetool

# Do the thing!
export VERSION="$(echo "$version" | awk -F"/" '{print $(NF-1)}')"
export ARCH=x86_64
./appimagetool --comp zstd --mksquashfs-opt -Xcompression-level --mksquashfs-opt 20 ./$APP.AppDir Ryujinx-"$VERSION"-"$ARCH".AppImage
[ -n "$APP" ] && mv ./*.AppImage .. && cd .. && rm -rf ./"$APP" || exit 1
echo "All Done!"
