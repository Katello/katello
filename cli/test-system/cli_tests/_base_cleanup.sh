#!/bin/bash

header "Basic environment cleanup"

#clear
todo "filter delete" filter delete --org="$TEST_ORG" --name="$FILTER1"
todo "repo delete" "not yet implemented" repo delete --product="$FEWUPS_PRODUCT" --org="$TEST_ORG" --name="$FEWUPS_REPO"
todo "product delete" "not yet implemented" product delete --provider="$YUM_PROVIDER" --org="$TEST_ORG" --name="$FEWUPS_PRODUCT"
test_success "provider delete" provider delete --name="$YUM_PROVIDER" --org="$TEST_ORG"
test_success "environment delete" environment delete --name="$TEST_ENV" --org="$TEST_ORG"
test_success "environment delete" environment delete --name="$TEST_ENV_3" --org="$TEST_ORG"
test_success "org delete" org delete --name="$TEST_ORG"
test_success "user delete" user delete --username="$TEST_USER"
