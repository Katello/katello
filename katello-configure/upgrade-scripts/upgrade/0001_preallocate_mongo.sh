#!/bin/bash

#name: Preallocate MongoDB journal
#apply: katello
#description: Journal is now enabled by default, we need to preallocate the space.

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

