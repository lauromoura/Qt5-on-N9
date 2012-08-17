#!/bin/sh

# Build and copy webkit to the device

HELP="Usage: ./$0 [options]\n
Copies the current directory to scratchbox, build, send and run Snowshoe on the N9.\n
Alternatively, a debian package can be generated and installed.\n
\n
Options:\n
\n
-b\t\t\tonly build the project, do not send to the device\n
-c\t\t\tmake distclean before building (only without -d)\n
-h\t\t\tshows this help message.\n
-i IP\t\t\tip of the target N9/N950 device.\n
-j JOBS\t\t\tnumber of parallel jobs during the build.\n
-l\t\t\tInstall only on scratchbox host.\n
-u USERNAME\t\tset username to connect to the device.\n
-p FOLDER\t\tpath to webkit folder *inside* scratchbox. Can be absolute or relative.\n
"

set -e

N9USER=developer
IP=192.168.2.15
BUILD_ONLY=0
LOCAL_ONLY=0
WEBKIT_SBOXDIR=/home/$USER/webkit
JOBS=1


while getopts p:i:u:j:blh ARG
do case "$ARG" in
    p) WEBKIT_SBOXDIR="$OPTARG";;
    i) IP="$OPTARG";;
    u) N9USER="$OPTARG";;
    b) BUILD_ONLY=1;;
	l) LOCAL_ONLY=1;;
	j) JOBS="$OPTARG";;
    h) echo -e $HELP && exit 0;;
    ?) echo -e $HELP && exit 1;;
esac
done
export N9=$N9USER@$IP

echo "Project folder: $WEBKIT_SBOXDIR"
echo "Build only? $BUILD_ONLY"
echo "Local install only? $LOCAL_ONLY"

if test $BUILD_ONLY -eq 0; then

echo "Checking connection to the device..."
if ping -c 2 -w 2 192.168.2.15; then
	echo "Connected to N9"
else
	echo "Not connected to N9. Exiting."
	exit 1
fi

fi # BUILD_ONLY == 0

WEBKIT_TMPDIR=`mktemp -d`

echo "Building QtWebKit"

# Build
/scratchbox/login -s <<EOF
export PATH=/opt/qt5/bin:\$PATH
export SBOX_REDIRECT_IGNORE=\$SBOX_REDIRECT_IGNORE:/usr/bin/perl
cd $WEBKIT_SBOXDIR
Tools/Scripts/build-webkit --qt --release --makeargs="-j$JOBS" --qmakearg="CONFIG+=use_qt_mobile_theme"
EOF

if test $BUILD_ONLY -eq 1; then
	exit 0
fi

# Install
echo "Installing to local system"
/scratchbox/login -s <<EOF
export PATH=/opt/qt5/bin:\$PATH
export SBOX_REDIRECT_IGNORE=\$SBOX_REDIRECT_IGNORE:/usr/bin/perl
cd $WEBKIT_SBOXDIR
echo "Copying files to scratchbox root."
fakeroot make -C WebKitBuild/Release/ install
EOF

if test $LOCAL_ONLY -eq 1; then
	exit 0
fi

# Install to temporary dir to copy
echo "Installing to temporary folder before sending to N9."
/scratchbox/login -s <<EOF
export PATH=/opt/qt5/bin:\$PATH
export SBOX_REDIRECT_IGNORE=\$SBOX_REDIRECT_IGNORE:/usr/bin/perl
cd $WEBKIT_SBOXDIR
echo "Copying files to be installed to temporary directory $WEBKIT_TMPDIR"
make -C WebKitBuild/Release/ install INSTALL_ROOT=$WEBKIT_TMPDIR
EOF

echo "Sending files to the device"
tar czf - $WEBKIT_TMPDIR | ssh $N9 "cd /home/developer; tar xzof -"

echo "Copying files to the proper places on the device."
ssh $N9 "chmod 755 /home/developer$WEBKIT_TMPDIR"
ssh -t $N9 "devel-su -c \"cp -Rv /home/developer$WEBKIT_TMPDIR/* /\""

echo "Removing temporary files on the device"
ssh $N9 "rm -rf /home/developer/$WEBKIT_TMPDIR"

echo "Removing temporary directory on host."
rm -rf WEBKIT_TMPDIR
