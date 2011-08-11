#!/bin/bash

#testing ping
test "ping" ping

# DEFAULT GLOBAL VARIABLES
FIRST_ORG=ACME_Corporation
TEST_USER="user_$RAND"
TEST_ORG="org_$RAND"
TEST_ENV="env_$RAND"
TEST_ENV_3="env_3_$RAND"
YUM_PROVIDER="yum_provider_$RAND"
FEWUPS_REPO_URL="http://lzap.fedorapeople.org/fakerepos/"
FEWUPS_PRODUCT="fewups_product_$RAND"
FEWUPS_REPO="repo_$RAND"

# BASIC RESOURCES (reused in tests)
test "user create" user create --username=$TEST_USER --password=password
test "org create" org create --name=$TEST_ORG --description="org description"
test "environment create" environment create --org="$FIRST_ORG" --name="$TEST_ENV" --prior="Locker"
test "environment create" environment create --org="$FIRST_ORG" --name="$TEST_ENV_3" --prior="$TEST_ENV"
test "provider create" provider create --name="$YUM_PROVIDER" --org="$FIRST_ORG" --type=custom --url="$FEWUPS_REPO_URL" --description="prov description"
test "product create" product create --provider="$YUM_PROVIDER" --org="$FIRST_ORG" --name="$FEWUPS_PRODUCT" --url="$FEWUPS_REPO_URL"
test "repo create" repo create --product="$FEWUPS_PRODUCT" --org="$FIRST_ORG" --name="$FEWUPS_REPO" --url="$FEWUPS_REPO_URL" --assumeyes
