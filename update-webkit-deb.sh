#!/bin/sh

# Updates the debian folder to the latest release. It assumes a webkit git clone
# with a working 'debianize' branch with the debian folder. The version number
# will be the latest '"$REMOTE"/master' SVN release.

# usage: $0 [revision]

set -e
DIR="$(cd "$( dirname "$0")" && pwd )"

. $DIR/config.sh

cd "$SBOXHOME/$WEBKITFOLDER"

git fetch "$REMOTE"

if [ -z "$1" ];
then
    echo "Using latest snapshot"
    commit=$(git log -n 1 --format=format:%H "$REMOTE"/master)
    svnrevision=$(git log -n 1 "$REMOTE"/master | grep git-svn-id | sed -E "s/.*@([0-9]*).*/\\1/")
else
    echo "Using specific revision $1"
    svnrevision="$1"
    commit=$(git log -n 1 --format=format:%H --grep "trunk@$svnrevision" "$REMOTE"/master)
fi

echo "Revision $svnrevision and commit $commit"

git checkout "$BRANCH"

if [ -z "$commit" ]; then
    echo "Revision not found. Building current version."
elif git log --format=format:%H | grep -qs "$commit"; then
    echo "Already merged, just rebuild."
else
    git merge "$commit"

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
