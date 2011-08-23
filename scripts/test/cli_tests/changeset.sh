#!/bin/bash

# synchronize repo to load the packages
test "repo synchronize" repo synchronize --repo_id="$REPO_ID"

# testing changesets
CS_NAME="changeset_$RAND"
CS_NAME_2="changeset_2_$RAND"
test "changeset create" changeset create --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME"
test "changeset add product" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" --add_product="$FEWUPS_PRODUCT"

jobs=`ps aux | grep -v grep | grep "rake jobs:work"`
if [ "$jobs" == "" ]; then
    printf "${txtred}Warning: Jobs daemon is not running, the promotion will hang!${txtrst}\n"
    printf "${txtred}Start 'rake jobs:work' to proceed.${txtrst}\n"
fi

test "promote changeset with one product" changeset promote --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME"

test "changeset create" changeset create --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2"
test "changeset add package" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --add_package="cheetah"
test "changeset add erratum" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --add_erratum="RHEA-2010:9984"
test "changeset add repo" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --add_repo="$REPO_NAME"
test "changeset promote" changeset promote --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2"

test "changeset remove product" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" --remove_product="$FEWUPS_PRODUCT"
test "changeset remove package" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --remove_package="cheetah"
test "changeset remove erratum" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --remove_erratum="RHEA-2010:9984"
test "changeset remove repo" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --remove_repo="$REPO_NAME"

test "changeset list" changeset list --org="$TEST_ORG" --environment="$TEST_ENV"
test "changeset info" changeset info --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" 


