#!/bin/bash
if [ $1 = "-i" ]; then
    echo "synchronizes all repositories in ACME_Corporation"
    return
fi

#sync all added repositories
for id in `$CMD repo list --org ACME_Corporation | tail -n +6 | awk '{print $1}'`; do
    $CMD repo synchronize --id $id
done


