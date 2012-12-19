#!/bin/bash

header "Product"

test_success "product list by org and env" product list --org="$TEST_ORG" --environment="$TEST_ENV" --provider="$YUM_PROVIDER"
test_success "product list by org only" product list --org="$TEST_ORG"
test_success "product list by org and provider" product list --org="$TEST_ORG" --provider="$YUM_PROVIDER"
test_success "product status" product status --org="$TEST_ORG" --name="$FEWUPS_PRODUCT"
