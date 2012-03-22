#!/bin/sh


SBOX_HOME=/scratchbox/users/$USER/home/$USER
PROJECTFOLDER_HOST=$(pwd -P)
PROJECTFOLDER=$(basename $PROJECTFOLDER_HOST)-tmp

LOGFILE=/tmp/$PROJECTFOLDER.txt

# N9 configuration.
N9=developer@192.168.2.15
N9HOME=/home/developer

echo "rsync $PROJECTFOLDER_HOST to $SBOX_HOME/$PROJECTFOLDER"
rsync -azrptL --progress --exclude-from=".gitignore" --exclude ".git" $PROJECTFOLDER_HOST/ $SBOX_HOME/$PROJECTFOLDER

# Build project
scratchbox -s <<EOF
cd $PROJECTFOLDER
export PATH=/opt/qt5/bin:\$PATH
make distclean
qmake
make -j 3
EOF

#FIXME Assuming executable name is the same as the folder
scp $SBOX_HOME/$PROJECTFOLDER/${PROJECTFOLDER%-tmp} $N9:$N9HOME
