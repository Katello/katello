#!/bin/bash


#clear
#test "repo delete" repo delete       # <-- not implemented yet
#test "product delete" product delete # <-- not implemented yet
test "provider delete" provider delete --name="$YUM_PROVIDER" --org="$FIRST_ORG"
test "environment delete" environment delete --name="$TEST_ENV" --org="$FIRST_ORG"
test "environment delete" environment delete --name="$TEST_ENV_3" --org="$FIRST_ORG"
test "org delete" org delete --name="$TEST_ORG"
test "user delete" user delete --username="$TEST_USER"

summarize

