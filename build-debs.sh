#!/bin/sh

# Builds all qt modules.

set -e

# FIXME hardcoded module order
for i in qtbase qtjsbackend qtxmlpatterns qtscript qtdeclarative qt3d qtlocation qtsensors; do
	cd $i
	dpkg-buildpackage -rfakeroot -uc -us
	# FIXME line below does not work on scratchbox
	#notify-send "Build of $i finished."
	# FIXME Works for scratchbox
	fakeroot dpkg -i ../qt5-*.deb
	cd ..
done
