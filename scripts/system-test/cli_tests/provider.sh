#!/bin/bash

header "Provider"

test_success "provider update" provider update --name="$YUM_PROVIDER" --org="$TEST_ORG" --description="prov description blah 2"
test_success "provider list" provider list --org="$TEST_ORG"
test_success "provider info" provider info --name="$YUM_PROVIDER" --org="$TEST_ORG"
test_success "provider status" provider status --name="$YUM_PROVIDER" --org="$TEST_ORG"
