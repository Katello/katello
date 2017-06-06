#!/bin/bash

header "Organization"

test_success "org update" org update --name="$TEST_ORG" --description="org description 2"
test_success "org list" org list
test_success "org info" org info --name="$TEST_ORG"
test_success "org subscriptions" org subscriptions --name="$TEST_ORG"
test_success "org default_info add" org default_info add --name="$TEST_ORG" --type=system --keyname=asset_tag
test_success "org default_info remove" org default_info remove --name="$TEST_ORG" --type=system --keyname=asset_tag
