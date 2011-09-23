#!/bin/bash

header "Repo"

test_success "repo list by org and env" repo list --org="$TEST_ORG" --environment="$TEST_ENV"
test_success "repo list by org only" repo list --org="$TEST_ORG"
test_success "repo list by org and product" repo list --org="$TEST_ORG" --product="$FEWUPS_PRODUCT"
REPO_NAME=`$CMD repo list --org="$TEST_ORG" -g | grep $FEWUPS_REPO | awk '{print $2}'`
REPO_ID=$(get_repo_id)
test_success "repo status" repo status --id="$REPO_ID"
test_success "repo synchronize" repo synchronize --id="$REPO_ID"
