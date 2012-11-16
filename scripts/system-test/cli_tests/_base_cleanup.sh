#!/bin/bash

header "Basic environment cleanup"

#clear

test_success "filter delete" filter delete --org="$TEST_ORG" --name="$FILTER1"
test_success "org delete" org delete --name="$TEST_ORG"
test_success "user delete" user delete --username="$TEST_USER"
