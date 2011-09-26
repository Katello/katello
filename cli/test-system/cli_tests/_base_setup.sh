#!/bin/bash

header "Basic environment setup"

#testing ping
test_success "ping" ping

# DEFAULT GLOBAL VARIABLES
TEST_USER="user_$RAND"
TEST_ORG="org_$RAND"
TEST_ENV="env_$RAND"
TEST_ENV_3="env_3_$RAND"
YUM_PROVIDER="yum_provider_$RAND"
FEWUPS_REPO_URL="http://lzap.fedorapeople.org/fakerepos/zoo/"
FEWUPS_PRODUCT="fewups_product_$RAND"
FEWUPS_REPO="repo_$RAND"

# BASIC RESOURCES (reused in tests)
test_success "user create" user create --username=$TEST_USER --password=password
test_success "org create" org create --name=$TEST_ORG --description="org description"
test_success "environment create" environment create --org="$TEST_ORG" --name="$TEST_ENV" --prior="Locker"
test_success "environment create" environment create --org="$TEST_ORG" --name="$TEST_ENV_3" --prior="$TEST_ENV"
test_success "provider create" provider create --name="$YUM_PROVIDER" --org="$TEST_ORG" --type=custom --url="$FEWUPS_REPO_URL" --description="prov description"
test_success "product create" product create --provider="$YUM_PROVIDER" --org="$TEST_ORG" --name="$FEWUPS_PRODUCT" --url="$FEWUPS_REPO_URL" --assumeyes
test_success "repo create" repo create --product="$FEWUPS_PRODUCT" --org="$TEST_ORG" --name="$FEWUPS_REPO" --url="$FEWUPS_REPO_URL"
REPO_NAME=`$CMD repo list --org="$TEST_ORG" | grep $FEWUPS_REPO | awk '{print $2}'`
REPO_ID=$(get_repo_id)
