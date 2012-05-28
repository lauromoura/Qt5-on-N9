#!/bin/sh

# Generate a /tmp/release.txt info file for a given Qt5 hash

QT_HOME="$1"
HASH="$2"
BRANCH="gitorious"


cd "$QT_HOME"

git remote update
git submodule foreach git fetch "$BRANCH"
git checkout "$HASH"
git submodule update --recursive
git submodule status | awk '/^ / { print $1 " " $2 }' > /tmp/release.txt