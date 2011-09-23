#!/bin/bash

header "Package group"

REPO_ID=$(get_repo_id)
PACKAGE_GROUP_ID=test
PACKAGE_GROUP_CATEGORY_ID=test
create_sample_package_groups

test "list package groups" package_group list --repoid $REPO_ID
test "show package group" package_group info --repoid $REPO_ID --id $PACKAGE_GROUP_ID

test "list package group categories" package_group category_list --repoid $REPO_ID
test "shod pacakge group category" package_group category_info --repoid $REPO_ID --id $PACKAGE_GROUP_CATEGORY_ID
