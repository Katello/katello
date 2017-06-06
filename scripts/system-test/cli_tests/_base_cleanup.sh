#!/bin/bash

header "Basic environment cleanup"

#clear

test_success "org delete" org delete --name="$TEST_ORG"
test_success "user delete" user delete --username="$TEST_USER"
