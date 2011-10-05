#!/bin/bash

header "Package group"

REPO_ID=$(get_repo_id)
PACKAGE_GROUP_ID=test
PACKAGE_GROUP_NAME=test
PACKAGE_GROUP_CATEGORY_ID=test
PACKAGE_GROUP_CATEGORY_NAME=test
create_sample_package_groups

test_success "list package groups" package_group list --repo_id $REPO_ID
test_success "show package group" package_group info --repo_id $REPO_ID --id $PACKAGE_GROUP_ID

test_success "list package group categories" package_group category_list --repo_id $REPO_ID
test_success "shod pacakge group category" package_group category_info --repo_id $REPO_ID --id $PACKAGE_GROUP_CATEGORY_ID
