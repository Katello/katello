#!/bin/bash

header "Environment"

ENV="tstenv_$RAND"
ENV2="tstenv2_$RAND"
test_success "environment create" environment create --org="$TEST_ORG" --name="$ENV" --prior="Library"
test_success "environment update" environment update --org="$TEST_ORG" --name="$ENV" --new_name="$ENV2"
test_success "environment list" environment list --org="$TEST_ORG"
test_success "environment info" environment info --org="$TEST_ORG" --name="$ENV2"
test_success "environment delete" environment delete --org="$TEST_ORG" --name="$ENV2"
