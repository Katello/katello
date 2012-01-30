#!/bin/bash

header "Product"

test_success "product list by org and env" product list --org="$TEST_ORG" --environment="$TEST_ENV" --provider="$YUM_PROVIDER"
test_success "product list by org only" product list --org="$TEST_ORG"
test_success "product list by org and provider" product list --org="$TEST_ORG" --provider="$YUM_PROVIDER"
test_success "product filter_list" product list_filters --org="$TEST_ORG" --name="$FEWUPS_PRODUCT"
test_success "product add_filter" product add_filter --org="$TEST_ORG" --name="$FEWUPS_PRODUCT" --filter="$FILTER1"
test_success "product remove_filter" product remove_filter --org="$TEST_ORG" --name="$FEWUPS_PRODUCT" --filter="$FILTER1"
