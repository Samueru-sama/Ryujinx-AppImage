# Ryujinx-AppImage
Unofficial AppImage of the Ryujinx emulator: https://github.com/Ryujinx/Ryujinx

Uses the portable release of Ryujinx and turns it into an AppImage: https://github.com/Ryujinx/release-channel-master

You can also run the `ryujinx-appimage.sh` script in your machine to make the AppImage.

It is possible that this appimage may fail to work with appimagelauncher, since appimagelauncher is pretty much dead I recommend this alternative: https://github.com/ivan-hc/AM

This appimage works without `fuse2` as it can use `fuse3` instead, however you will need to run this command to symlink fusermount to fusermount3 otherwise you will get a missing fusermount error: 

`sudo ln -s /usr/bin/fusermount3 /usr/bin/fusermount`
