#!/bin/sh

# Builds all qt modules.

set -e

# FIXME hardcoded module order
for i in base jsbackend xmlpatterns script declarative quick1 3d jsondb location sensors; do

# FIXME hardcoded repo paths
scratchbox -s <<EOF
export PATH=/opt/qt5/bin:\$PATH
export CFLAGS=" "
export CPPFLAGS=" "
export CXXFLAGS=" "
cd qt/qt5-debs/qt$i
dpkg-buildpackage -rfakeroot -uc -us 2>&1 | tee /tmp/build-$i.log
fakeroot dpkg -i ../*$i*.deb
EOF

done
