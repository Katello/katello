#!/bin/bash

header "Changeset"

# synchronize repo to load the packages
#test_success "repo synchronize" repo synchronize --id="$REPO_ID"
test_success "product synchronize" product synchronize --org="$TEST_ORG" --name="$FEWUPS_PRODUCT"

# testing changesets
CS_NAME="changeset_$RAND"
CS_NAME_2="changeset_2_$RAND"
CS_NAME_3="changeset_3_$RAND"
test_success "changeset create" changeset create --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME"
test_success "changeset add product" changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" --add_product="$FEWUPS_PRODUCT"

check_delayed_jobs_running

test_success "promote changeset with one product" changeset promote --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME"

test_success "changeset create" changeset create --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2"
test_success "changeset add package"  changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --add_package="monkey-0.3-0.8.noarch"
test_success "changeset add erratum"  changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --add_erratum="RHEA-2010:0001"
test_success "changeset add repo"     changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --add_repo="$REPO_NAME"

test_success "changeset promote" changeset promote --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2"

test_success "changeset list" changeset list --org="$TEST_ORG" --environment="$TEST_ENV"
test_success "changeset info" changeset info --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME"

test_success "changeset remove product"  changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" --remove_product="$FEWUPS_PRODUCT"
test_success "changeset remove package"  changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --remove_package="monkey-0.3-0.8.noarch"
test_success "changeset remove erratum"  changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --remove_erratum="RHEA-2010:0001"
test_success "changeset remove repo"     changeset update  --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME_2" --from_product="$FEWUPS_PRODUCT" --remove_repo="$REPO_NAME"

test_success "changeset update" changeset update --org="$TEST_ORG" --environment="$TEST_ENV" --name="$CS_NAME" --new_name="new_$CS_NAME" --description="updated description"
