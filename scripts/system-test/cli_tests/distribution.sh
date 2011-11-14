#!/bin/bash

header "Distribution"

test_success "distribution list by repo id" distribution list --repo_id="$REPO_ID"
test_success "distribution list" distribution list --repo="$REPO_NAME" --org="$TEST_ORG" --product="$FEWUPS_PRODUCT"
