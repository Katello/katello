#!/bin/bash


#testing packages
test "package list by repo id" package list --repo_id="$REPO_ID"
test "package list" package list --repo="$REPO_NAME" --org="$TEST_ORG" --product="$FEWUPS_PRODUCT"
PACK_ID=`$CMD package list --repo_id="$REPO_ID" -g | tail -n 1 | awk '{print $1}'`
if valid_id $PACK_ID; then
    test "package info" package info --id="$PACK_ID"
fi
