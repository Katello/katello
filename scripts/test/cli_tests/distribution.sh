#!/bin/bash


#testing distributions
test "distribution list by repo id" distribution list --repo_id="$REPO_ID"
test "distribution list" distribution list --repo="$REPO_NAME" --org="$FIRST_ORG" --product="$FEWUPS_PRODUCT"
