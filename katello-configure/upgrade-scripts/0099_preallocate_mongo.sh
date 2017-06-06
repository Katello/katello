#!/bin/bash

#name: Preallocate MongoDB journal
#apply: katello
#run: once
#description:
#With Mongo 1.8+ journal is enabled by default and it is necessary to create
#it manually, otherwise mongod daemon delays with start which can lead to
#errors during service startup. This step creates the journal only if it
#is not created yet.

# make sure the directory exists
mkdir /var/lib/mongodb/journal/ 2>/dev/null

# if journal does not exist, preallocate it
if [ ! -f "/var/lib/mongodb/journal/j._0" ]; then
  for J in 0 1 2; do
    echo "Preallocating 1 GB journal number $J of 3"
    dd if=/dev/zero of=/var/lib/mongodb/journal/prealloc.$J bs=1M count=1K
  done
  chmod 600 /var/lib/mongodb/journal/prealloc*
  chown mongodb:mongodb /var/lib/mongodb/journal/prealloc*
else
  echo "Journals are already allocated, skipping"
  exit 0
fi
