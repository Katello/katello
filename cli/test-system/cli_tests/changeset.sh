#!/bin/bash

require "template"

header "Changeset"

# synchronize repo to load the packages
test_success "repo synchronize" repo synchronize --id="$REPO_ID"

# testing changesets
CS_NAME="changeset_$RAND"
CS_NAME_2="changeset_2_$RAND"
test_success "changeset create" changeset create --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME"
test_success "changeset add product" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" --add_product="$FEWUPS_PRODUCT"

jobs_rake=`ps aux | grep -v grep | grep "rake jobs:work" > /dev/null; echo $?`
jobs_service=`service katello-jobs status > /dev/null ; echo $?`

if ! jobs_running; then
    printf "${txtred}Warning: Jobs daemon is not running, the promotion will hang!${txtrst}\n"
    printf "${txtred}Start 'rake jobs:work' to proceed.${txtrst}\n"
fi

test_success "promote changeset with one product" changeset promote --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME"
sleep 5 # sqlite concurrency workaround

test_success "changeset create" changeset create --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2"
test_success "changeset add package" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --add_package="cheetah"
test_success "changeset add erratum" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --add_erratum="RHEA-2010:9984"
test_success "changeset add repo" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --add_repo="$REPO_NAME"
test_success "changeset promote" changeset promote --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2"

test_success "changeset remove product" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" --remove_product="$FEWUPS_PRODUCT"
test_success "changeset remove package" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --remove_package="cheetah"
test_success "changeset remove erratum" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --remove_erratum="RHEA-2010:9984"
test_success "changeset remove repo" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --remove_repo="$REPO_NAME"

test_success "changeset list" changeset list --org="$TEST_ORG" --environment="$TEST_ENV"
test_success "changeset info" changeset info --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME"
