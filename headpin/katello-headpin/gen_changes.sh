#!/bin/bash
HEADPIN=$PWD
CHANGES_FILE="file_changes.txt"

# Clear out the old things
rm $CHANGES_FILE
rm -rf src

# generate the new file
git diff master --name-only | grep -v "katello.spec" | grep "^src/"   > $CHANGES_FILE

# Copy over the changes
cd ../..
while read change
do
    cp --parents $change $HEADPIN
done < $HEADPIN/$CHANGES_FILE
cd $HEADPIN
