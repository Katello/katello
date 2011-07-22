#!/bin/bash



#testing changesets
CS_NAME="changeset_$RAND"
test "changeset create" changeset create --org="$FIRST_ORG" --environment="$TEST_ENV" --name="$CS_NAME"
test "changeset add product" changeset update  --org="$FIRST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" --add_product="$FEWUPS_PRODUCT"
test "changeset add package" changeset update  --org="$FIRST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" --add_package="warnerbros"
test "changeset add erratum" changeset update  --org="$FIRST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" --add_erratum="RHEA-2010:9999"
test "changeset add repo" changeset update  --org="$FIRST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" --add_repo="$REPO_NAME"
test "changeset promote" changeset promote --org="$FIRST_ORG" --environment="$TEST_ENV" --name="$CS_NAME"
test "changeset remove product" changeset update  --org="$FIRST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" --remove_product="$FEWUPS_PRODUCT"
test "changeset remove package" changeset update  --org="$FIRST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" --remove_package="warnerbros"
test "changeset remove erratum" changeset update  --org="$FIRST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" --remove_erratum="RHEA-2010:9999"
test "changeset remove repo" changeset update  --org="$FIRST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" --remove_repo="$REPO_NAME"
test "changeset list" changeset list --org="$FIRST_ORG" --environment="$TEST_ENV"
test "changeset info" changeset info --org="$FIRST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" 


