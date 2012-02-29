#!/bin/sh

# Updates the debianize branches, merging new commits and updating the version.
#
# The target hashes and modules are provided by a TIMESTAMP.txt file, with lines
# in the format "<HASH> <MODULE>". Only the two first fields are relevant. Example
# from the emails with the updated hashes:
# 79ebb1621e6cdb68a4ad107c8ac80eadb9c60366 qtbase (heads/master-1337-g79ebb16)
# 18a51f0732a3276fbe314433a090efafeb6e22d4 qtdeclarative (heads/master-641-g18a51f0)
# d83defb0103a82ffef1e0f572d18845b04c3b6f4 qtscript (remotes/origin/HEAD)
# ...


set -e

VERSION="5.0.0"
BRANCH="debianize"
DISTRIBUTION="unstable"

merge_module() {

    module=$1
    commit=$2
    timestamp=$3

    echo "Processing $module with commit $commit"

    cd $module

        git checkout "$BRANCH"

        # check if this hash has already been merged
        if git log --format=format:%H | grep -qs "$commit"; then
            COMMIT_MESSAGE="Rebuild."
        else
            git merge $commit
            COMMIT_MESSAGE="New version."
        fi
        echo "Module $module: $COMMIT_MESSAGE."

        # Debian stuff
        dch -D "$DISTRIBUTION" --force-distribution -v $VERSION~$TIMESTAMP $COMMIT_MESSAGE

        git add debian/changelog

        git commit -m "Bump changelog"

    cd ..
}

FILENAME=$(basename $1)
TIMESTAMP=${FILENAME%.*}

echo "$FILENAME"
echo "$TIMESTAMP"

while read line
do
    commit=$( echo $line | awk '{ print $1}' )
    module=$( echo $line | awk '{ print $2}' )

    merge_module $module $commit $timestamp
done < "$1"
