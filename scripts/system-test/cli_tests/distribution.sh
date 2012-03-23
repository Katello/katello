#!/bin/bash

require 'repo'

ZOO_DISTRO_ID="ks-Test Family-TestVariant-16-x86_64"
ZOO_DISTRO_NAME="$ZOO_DISTRO_ID"

header "Distribution"

test_success "distribution list by repo id" distribution list --repo_id="$REPO_ID"
test_success "distribution list" distribution list --repo="$REPO_NAME" --org="$TEST_ORG" --product="$FEWUPS_PRODUCT"
test_success "distribution info" distribution info --repo_id="$REPO_ID" --id="$ZOO_DISTRO_ID"
