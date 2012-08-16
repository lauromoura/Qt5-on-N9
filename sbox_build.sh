#!/bin/sh

# Build and copy webkit to the device



set -e

if [ ! $WEBKIT_SBOXDIR ]; then
	echo "Setting default WEBKIT_SBOXDIR"
	export WEBKIT_SBOXDIR=/home/$USER/webkit
else
	echo "Using previously set WEBKIT_SBOXDIR";
fi

echo "Checking connection to the device..."
if ping -c 2 -w 2 192.168.2.15; then
	echo "Connected to N9"
else
	echo "Not connected to N9. Exiting."
	exit 1
fi

export WEBKIT_TMPDIR=`mktemp -d`

echo "Building QtWebKit"
# Commands to be run inside scratchbox
/scratchbox/login -s <<EOF
export PATH=/opt/qt5/bin:\$PATH
export SBOX_REDIRECT_IGNORE=\$SBOX_REDIRECT_IGNORE:/usr/bin/perl
cd $WEBKIT_SBOXDIR
Tools/Scripts/build-webkit --qt --release --makeargs="-j9" --qmakearg="CONFIG+=use_qt_mobile_theme"
echo "Copying files to be installed to temporary directory $WEBKIT_TMPDIR"
make -C WebKitBuild/Release/ install INSTALL_ROOT=$WEBKIT_TMPDIR
fakeroot make -C WebKitBuild/Release/ install
EOF

export N9=developer@192.168.2.15

echo "Sending files to the device"
tar czf - $WEBKIT_TMPDIR | ssh $N9 "cd /home/developer; tar xzof -"

echo "Copying files to the proper places on the device."
ssh $N9 "chmod 755 /home/developer$WEBKIT_TMPDIR"
ssh $N9 "devel-su -c \"cp -Rv /home/developer$WEBKIT_TMPDIR/* /\""

echo "Removing temporary files on the device"
ssh $N9 "rm -rf /home/developer/webkit_transfer/*"

echo "Removing temporary directory on host."
rm -rf WEBKIT_TMPDIR
