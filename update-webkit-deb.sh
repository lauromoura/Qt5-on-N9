#!/bin/sh

# find the right qmake
SBOXHOME=/scratchbox/users/$USERNAME/home/$USERNAME
WEBKITFOLDER=qt5/webkit-deb
cd "$SBOXHOME/$WEBKITFOLDER"

git fetch

commit=$(git log -n 1 --format=format:%H origin/master)
svnrevision=$(git log -n 1 origin/master | grep git-svn-id | sed -E "s/.*@([0-9]*).*/\\1/")
git checkout debianize

if git log --format=format:%H | grep -qs "$commit"; then
	echo
else
	git merge origin/master

	dch -D unstable --force-distribution -v "$svnrevision" "New snapshot."

	git add debian/changelog

	git commit -m "New release."
fi

# finally build.
echo "cd $WEBKITFOLDER; export PATH=/opt/qt5/bin:\$PATH; dpkg-buildpackage -rfakeroot -uc -us -B" | scratchbox -s
