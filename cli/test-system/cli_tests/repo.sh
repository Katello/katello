#!/bin/bash

header "Repo"

test_success "repo list by org and env" repo list --org="$TEST_ORG" --environment="$TEST_ENV"
test_success "repo list by org only" repo list --org="$TEST_ORG"
test_success "repo list by org and product" repo list --org="$TEST_ORG" --product="$FEWUPS_PRODUCT"
REPO_NAME=`$CMD repo list --org="$TEST_ORG" -g | grep $FEWUPS_REPO | awk '{print $2}'`
REPO_ID=$(get_repo_id)
test_success "repo status" repo status --id="$REPO_ID"
test_success "repo synchronize" repo synchronize --id="$REPO_ID"

PACKAGE_URL=https://localhost/pulp/repos/$TEST_ORT/$TEST_ORG/Locker/$FEWUPS_PRODUCT/$REPO_NAME/lion-0.3-0.8.noarch.rpm
REPO_STATUS_CODE=`curl $PACKAGE_URL -k --write-out '%{http_code}' -s -o /dev/null`
if [ $REPO_STATUS_CODE != '401' ]; then
  msg_status "repo secured" "${txtred}FAILED${txtrst}"
  echo "We expected the pulp repo to be sucured (status code 401), got $REPO_STATUS_CODE"
  let failed_cnt+=1
fi
