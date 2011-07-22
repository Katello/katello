#!/bin/bash


#testing ping
test "ping" ping

#testing user
TEST_USER="user_$RAND"
test "user create" user create --username=$TEST_USER --password=password
test "user update" user update --username=$TEST_USER --password=password
test "user list" user list
test "user info" user info --username=$TEST_USER

#testing organization
FIRST_ORG=ACME_Corporation
TEST_ORG="org_$RAND"
test "org create" org create --name=$TEST_ORG --description="org description"
test "org update" org update --name=$TEST_ORG --description="org description 2"
test "org list" org list
test "org info" org info --name=$TEST_ORG

#testing environments
TEST_ENV="env_$RAND"
TEST_ENV_2="env_2_$RAND"
TEST_ENV_3="env_3_$RAND"
test "environment create" environment create --org="$FIRST_ORG" --name="$TEST_ENV" --prior="Locker"
test "environment create" environment create --org="$FIRST_ORG" --name="$TEST_ENV_2" --prior="$TEST_ENV"
test "environment update" environment update --org="$FIRST_ORG" --name="$TEST_ENV_2" --new_name="$TEST_ENV_3"
test "environment list" environment list --org="$FIRST_ORG"
test "environment info" environment info --org="$FIRST_ORG" --name="$TEST_ENV"

#testing provider
YUM_PROVIDER="yum_provider_$RAND"
FEWUPS_REPO="http://lzap.fedorapeople.org/fakerepos/"
FEWUPS_REPO_2="http://lzap.fedorapeople.org/fakerepos/2/"
test "provider create" provider create --name="$YUM_PROVIDER" --org="$FIRST_ORG" --type=yum --url="$FEWUPS_REPO" --description="prov description"
test "provider update" provider update --name="$YUM_PROVIDER" --org="$FIRST_ORG" --url="$FEWUPS_REPO_2" --description="prov description 2"
test "provider list" provider list --org="$FIRST_ORG"
test "provider info" provider info --name="$YUM_PROVIDER" --org="$FIRST_ORG"

#testing products
FEWUPS_PRODUCT="fewups_product_$RAND"
test "product create" product create --provider="$YUM_PROVIDER" --org="$FIRST_ORG" --name="$FEWUPS_PRODUCT" --url="$FEWUPS_REPO"
test "product list by org and env" product list --org="$FIRST_ORG" --environment="$TEST_ENV" --provider="$YUM_PROVIDER"
test "product list by org only" product list --org="$FIRST_ORG"
test "product list by org and provider" product list --org="$FIRST_ORG" --provider="$YUM_PROVIDER"

#testing repositories
REPO="repo_$RAND"
test "repo create" repo create --product="$FEWUPS_PRODUCT" --org="$FIRST_ORG" --name="$REPO" --url="$FEWUPS_REPO" --assumeyes
test "repo list by org and env" repo list --org="$FIRST_ORG" --environment="$TEST_ENV"
test "repo list by org only" repo list --org="$FIRST_ORG"
test "repo list by org and product" repo list --org="$FIRST_ORG" --product="$FEWUPS_PRODUCT"
REPO_NAME=`$CMD repo list --org="$FIRST_ORG" | grep $REPO | awk '{print $2}'`
REPO_ID=`$CMD repo list --org="$FIRST_ORG" | grep $REPO | awk '{print $1}'`
test "repo status" repo status --id="$REPO_ID"
test "repo synchronize" repo synchronize --id="$REPO_ID"


