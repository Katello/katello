#!/bin/bash

require "repo"

header "Package"

test_success "package list by repo id" package list --repo_id="$REPO_ID"
test_success "package list" package list --repo="$REPO_NAME" --org="$TEST_ORG" --product="$FEWUPS_PRODUCT"

SEARCHED_PACKAGE='monkey-0.3-0.8'
SEARCH_SUCCESS_QUERY='monkey-0.3*'
SEARCH_FAIL_QUERY='monkey-0.4*'
function package_search_test {
    $KATELLO_CMD package search --repo="$REPO_NAME" --org="$TEST_ORG" --product="$FEWUPS_PRODUCT" --query="$1" | grep -F "$SEARCHED_PACKAGE"
}
test_own_cmd_success "package search success" package_search_test $SEARCH_SUCCESS_QUERY
test_own_cmd_failure "package search fail" package_search_test $SEARCH_FAIL_QUERY

PACK_ID=`$CMD package list --repo_id="$REPO_ID" -g | tail -n 1 | awk '{print $1}'`
if valid_id $PACK_ID; then
    test_success "package info" package info --id="$PACK_ID" --repo_id="$REPO_ID" 
fi
