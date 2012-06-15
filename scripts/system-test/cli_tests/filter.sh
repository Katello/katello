#!/bin/bash

header "Filter"

FILTER2="filter2_$RAND"

test_success "filter list by org" filter list --org="$TEST_ORG"
test_success "filter create" filter create --org="$TEST_ORG" --name="$FILTER2" --description="description" --packages="package3, package4"
test_success "filter info" filter info --org="$TEST_ORG" --name="$FILTER2"
test_success "filter add_package" filter add_package --org="$TEST_ORG" --name="$FILTER2" --package="package5"
test_success "filter remove_package" filter remove_package --org="$TEST_ORG" --name="$FILTER2" --package="package4"
test_success "filter delete" filter delete --org="$TEST_ORG" --name="$FILTER2"
