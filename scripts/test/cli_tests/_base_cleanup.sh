#!/bin/bash

#clear
skip_test "repo delete" "not yet implemented" repo delete --product="$FEWUPS_PRODUCT" --org="$FIRST_ORG" --name="$FEWUPS_REPO"
skip_test "product delete" "not yet implemented" product delete --provider="$YUM_PROVIDER" --org="$FIRST_ORG" --name="$FEWUPS_PRODUCT"
test "provider delete" provider delete --name="$YUM_PROVIDER" --org="$FIRST_ORG"
test "environment delete" environment delete --name="$TEST_ENV" --org="$FIRST_ORG"
test "environment delete" environment delete --name="$TEST_ENV_3" --org="$FIRST_ORG"
test "org delete" org delete --name="$TEST_ORG"
test "user delete" user delete --username="$TEST_USER"

summarize
