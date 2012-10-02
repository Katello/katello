#!/bin/bash

header "Basic environment cleanup"

#clear
test_failure "repo delete" repo delete --product="$FEWUPS_PRODUCT" --org="$TEST_ORG" --name="$FEWUPS_REPO"
test_success "changeset create" changeset create --name=delete_repo --deletion --org="$TEST_ORG" --environment="$TEST_ENV"
test_success "changeset update" changeset update --name=delete_repo --org="$TEST_ORG" --environment="$TEST_ENV" --add_product="$FEWUPS_PRODUCT"
test_success "changeset promote" changeset promote --name=delete_repo --org="$TEST_ORG" --environment="$TEST_ENV"
test_success "repo delete" repo delete --product="$FEWUPS_PRODUCT" --org="$TEST_ORG" --name="$FEWUPS_REPO"

test_success "product delete" product delete --org="$TEST_ORG" --name="$FEWUPS_PRODUCT"
test_success "filter delete" filter delete --org="$TEST_ORG" --name="$FILTER1"
test_success "provider delete" provider delete --name="$YUM_PROVIDER" --org="$TEST_ORG"
test_success "environment delete" environment delete --name="$TEST_ENV_2" --org="$TEST_ORG"
test_success "environment delete" environment delete --name="$TEST_ENV" --org="$TEST_ORG"
test_success "org delete" org delete --name="$TEST_ORG"
test_success "user delete" user delete --username="$TEST_USER"
