#!/bin/bash

require "repo"

header "Package group"

REPO_ID=$(get_repo_id)
# predefined groups and categories in the zoo2 testing repo
PACKAGE_GROUP_ID=mammal
PACKAGE_GROUP_CATEGORY_ID=all

test_success "list package groups" package_group list --repo_id "$REPO_ID"
test_success "show package group" package_group info --repo_id "$REPO_ID" --id "$PACKAGE_GROUP_ID"

test_success "list package group categories" package_group category_list --repo_id "$REPO_ID"
test_success "show pacakge group category" package_group category_info --repo_id "$REPO_ID" --id "$PACKAGE_GROUP_CATEGORY_ID"
