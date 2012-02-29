#!/bin/sh

# Updates the debian folder to the latest release. It assumes a webkit git clone
# with a working 'debianize' branch with the debian folder. The version number
# will be the latest '"$REMOTE"/master' SVN release.

set -e

BRANCH="debianize"
DISTRIBUTION="unstable"
REMOTE="gitorious"

# Adjust the values below according to your scratchbox and webkit locations

SBOXHOME=/scratchbox/users/$USERNAME/home/$USERNAME
WEBKITFOLDER=qt5/webkit-deb

cd "$SBOXHOME/$WEBKITFOLDER"

git fetch "$REMOTE"

commit=$(git log -n 1 --format=format:%H "$REMOTE"/master)
svnrevision=$(git log -n 1 "$REMOTE"/master | grep git-svn-id | sed -E "s/.*@([0-9]*).*/\\1/")

git checkout "$BRANCH"

if git log --format=format:%H | grep -qs "$commit"; then
    # Already merged, just rebuild.
    echo
else
    git merge "$REMOTE"/master

    dch -D "$DISTRIBUTION" --force-distribution -v "$svnrevision" "New snapshot."

    git add debian/changelog

    git commit -m "New release."
fi

# finally build.
scratchbox -s <<EOF
cd $WEBKITFOLDER
export PATH=/opt/qt5/bin:\$PATH
dpkg-buildpackage -rfakeroot -uc -us -B 2>&1 | tee /tmp/build-webkit-$svnrevision.txt
EOF
