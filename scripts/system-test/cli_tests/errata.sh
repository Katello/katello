#!/bin/bash

header "Errata"
REPO_NAME=$(get_repo_name)
REPO_ID=$(get_repo_id)

test_success "repo synchronize" repo synchronize --id="$REPO_ID"
test_success "errata list by org" errata list --org="$TEST_ORG"
test_success "errata list by repo and type" errata list --org="$TEST_ORG" --product="$FEWUPS_PRODUCT" --repo="$REPO_NAME" --type="enhancements"
test_success "errata list by product and repo" errata list --org="$TEST_ORG" --product="$FEWUPS_PRODUCT" --repo="$REPO_NAME"
test_success "errata list by repo id" errata list --repo_id="$REPO_ID"
test_success "errata list by product, repo, and type" errata list --org="$TEST_ORG" --product="$FEWUPS_PRODUCT" --repo="$REPO_NAME" --type="enhancements"
test_success "errata list by type" errata list --org="$TEST_ORG" --type="enhancements"
test_success "errata list by severity" errata list --org="$TEST_ORG" --severity="critical"
test_success "errata list by product and type" errata list --org="$TEST_ORG" --product="$FEWUPS_PRODUCT" --type="enhancements"
ERRATA_ID=$($CMD errata list --repo_id "$REPO_ID" -g | tail -n1 | awk '{print $1}')
if [ "x$ERRATA_ID" != "x" ]; then
  test_success "errata info" errata info --repo_id "$REPO_ID" --id "$ERRATA_ID"
fi
