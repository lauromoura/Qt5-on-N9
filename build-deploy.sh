#!/bin/sh

PROJECTFOLDER_HOST=$(pwd -P)
PROJECTFOLDER=${PROJECTFOLDER_HOST#/scratchbox/users/$USER}

LOGFILE=/tmp/$(basename $PROJECTFOLDER).txt

# N9 configuration.
N9=developer@192.168.2.15
N9HOME=/home/developer

# Build deb
scratchbox -s <<EOF
cd $PROJECTFOLDER
export PATH=/opt/qt5/bin:\$PATH
dpkg-buildpackage -rfakeroot -uc -us -B 2>&1 | tee $LOGFILE
EOF

# Get the package name
DEBFILE=$(grep -o [-a-z0-9]*_[.0-9]*_armel\.deb $LOGFILE)

echo "Sending file $DEBFILE to device."

# Send to device and install
scp $PROJECTFOLDER_HOST/../$DEBFILE $N9:$N9HOME

# Do not spoil the root password :)
stty -echo
ssh $N9 "devel-su -c \"dpkg -i $N9HOME/$DEBFILE\""
stty echo
