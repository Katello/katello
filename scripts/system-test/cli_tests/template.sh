#!/bin/bash

require "repo"
require "packagegroup"

header "Template"

# testing templates
TEMPLATE_NAME="template_$RAND"
TEMPLATE_NAME_2="template_2_$RAND"
TEMPLATE_CS_NAME="changeset_tpl_$RAND"
test_success "template create" template create --name="$TEMPLATE_NAME" --description="template description" --org="$TEST_ORG"

test_success "template create with parent" template create --name="$TEMPLATE_NAME_2" --description="template 2 description" --parent="$TEMPLATE_NAME" --org="$TEST_ORG"
test_success "template update" template update --name="$TEMPLATE_NAME_2" --new_name="changed_$TEMPLATE_NAME_2" --description="changed description" --org="$TEST_ORG"

test_success "template list" template list --org="$TEST_ORG" --environment="Library"

test_success "template update add repo"                    template update --name="$TEMPLATE_NAME" --org="$TEST_ORG"  --from_product="$FEWUPS_PRODUCT" --add_repo="$REPO_NAME"
test_success "template update add package"                 template update --name="$TEMPLATE_NAME" --org="$TEST_ORG" --add_package="cheetah"
test_success "template update add package group"           template update --name="$TEMPLATE_NAME" --org="$TEST_ORG" --add_package_group="mammal"
test_success "template update add package group categrory" template update --name="$TEMPLATE_NAME" --org="$TEST_ORG" --add_package_group_category="all"
test_success "template update add parameter"               template update --name="$TEMPLATE_NAME" --org="$TEST_ORG" --add_parameter="attr" --value="X"
test_success "template update add distribution"            template update --name="$TEMPLATE_NAME" --org="$TEST_ORG" --add_distribution="ks-Test Family-TestVariant-16-x86_64"

check_delayed_jobs_running

test_success "create a changeset for promoting the template" changeset create  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$TEMPLATE_CS_NAME"
test_success "add template to the changeset"                 changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$TEMPLATE_CS_NAME" --add_template="$TEMPLATE_NAME"
test_success "promote a changeset with the template"         changeset promote --org="$TEST_ORG" --environment="$TEST_ENV" --name="$TEMPLATE_CS_NAME"

test_success "template export in tdl"                 template export --name="$TEMPLATE_NAME" --org="$TEST_ORG" --format=tdl  --file=/dev/null --environment="$TEST_ENV"
test_success "template export in json"                template export --name="$TEMPLATE_NAME" --org="$TEST_ORG" --format=json --file=/dev/null --environment="$TEST_ENV"
test_success "template export in json (default)"      template export --name="$TEMPLATE_NAME" --org="$TEST_ORG" --file=/dev/null --environment="$TEST_ENV"

test_success "template update remove parameter"              template update --name="$TEMPLATE_NAME" --org="$TEST_ORG" --remove_parameter="attr"
test_success "template update remove package group category" template update --name="$TEMPLATE_NAME" --org="$TEST_ORG" --remove_package_group_category="all"
test_success "template update remove package group"          template update --name="$TEMPLATE_NAME" --org="$TEST_ORG" --remove_package_group="mammal"
test_success "template update remove package"                template update --name="$TEMPLATE_NAME" --org="$TEST_ORG" --remove_package="cheetah"

test_failure "template update add unknown package" template update --name="$TEMPLATE_NAME" --org="$TEST_ORG" --add_package="does_not_exist"
test_failure "template update add unknown package" template update --name="$TEMPLATE_NAME" --org="$TEST_ORG" --add_package_group_category="does_not_exist"
