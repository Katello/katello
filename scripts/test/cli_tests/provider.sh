#!/bin/bash

#testing provider
test "provider update" provider update --name="$YUM_PROVIDER" --org="$TEST_ORG" --description="prov description blah 2"
test "provider list" provider list --org="$TEST_ORG"
test "provider info" provider info --name="$YUM_PROVIDER" --org="$TEST_ORG"
