#!/bin/bash

require "repo"

header "Template"

# testing templates
TEMPLATE_NAME="template_$RAND"
TEMPLATE_NAME_2="template_2_$RAND"
test_success "template create" template create --name="$TEMPLATE_NAME" --description="template description" --org="$TEST_ORG"

test_success "template create with parent" template create --name="$TEMPLATE_NAME_2" --description="template 2 description" --parent="$TEMPLATE_NAME" --org="$TEST_ORG"
test_success "template update" template update --name="$TEMPLATE_NAME_2" --new_name="changed_$TEMPLATE_NAME_2" --description="changed description" --org="$TEST_ORG"

test_success "template list" template list --org="$TEST_ORG" --environment="Locker"

test_success "template update_content add product" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG"    --add_product    --product="$FEWUPS_PRODUCT"
test_success "template update_content add package" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG"    --add_package    --package="cheetah"
test_success "template update_content remove package" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG" --remove_package --package="cheetah"
test_success "template update_content remove product" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG" --remove_product --product="$FEWUPS_PRODUCT"
test_success "template update_content add parameter" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG"    --add_parameter    --parameter "attr" --value "X"
test_success "template update_content remove parameter" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG" --remove_parameter --parameter "attr"

test_failure "template update_content add unknown product" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG"    --add_product    --product="this_product_does_not_exist"
test_failure "template update_content add unknown package" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG"    --add_package    --package="this_package_does_not_exist"

REPO_ID=$(get_repo_id)
PACKAGE_GROUP_ID=test
PACKAGE_GROUP_CATEGORY_ID=test
create_sample_package_groups

test_success "template update_content add package group" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG"    --add_package_group    --repo="$REPO_ID" --package_group "$PACKAGE_GROUP_ID"
test_success "template update_content remove package group" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG"    --remove_package_group    --repo="$REPO_ID" --package_group "$PACKAGE_GROUP_ID"

test_success "template update_content add package group categrory" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG"    --add_package_group_category    --repo="$REPO_ID" --package_group_category "$PACKAGE_GROUP_CATEGORY_ID"
test_success "template update_content remove package group" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG"    --remove_package_group_category    --repo="$REPO_ID" --package_group_category "$PACKAGE_GROUP_CATEGORY_ID"
