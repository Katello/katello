#!/bin/bash

header "Basic environment setup"

#testing ping
test_success "ping" ping

# DEFAULT GLOBAL VARIABLES
TEST_USER=$(nospace "user_$RAND")
TEST_ORG="org_$RAND"
TEST_ENV="env $RAND"
TEST_ENV_2="env_2 $RAND"
YUM_PROVIDER="yum_provider_$RAND"
FEWUPS_REPO_URL="http://lzap.fedorapeople.org/fakerepos/zoo5/"
FEWUPS_PRODUCT="fewups_product_$RAND"
FEWUPS_REPO="repo_$RAND"
FILTER1="filter_$RAND"

# BASIC RESOURCES (reused in tests)
test_success "user create ($TEST_USER)" user create --username="$TEST_USER" --password=password --email=$TEST_USER@somewhere.com
test_success "org create ($TEST_ORG)" org create --name="$TEST_ORG" --description="org description"
test_success "org uebercert" org uebercert --name="$TEST_ORG"
test_success "environment create ($TEST_ENV)" environment create --org="$TEST_ORG" --name="$TEST_ENV" --prior="Library"
test_success "environment create ($TEST_ENV_2)" environment create --org="$TEST_ORG" --name="$TEST_ENV_2" --prior="$TEST_ENV"
test_success "provider create ($YUM_PROVIDER)" provider create --name="$YUM_PROVIDER" --org="$TEST_ORG" --url="$FEWUPS_REPO_URL" --description="prov description"
test_success "product create ($FEWUPS_PRODUCT)" product create --provider="$YUM_PROVIDER" --org="$TEST_ORG" --name="$FEWUPS_PRODUCT" --url="$FEWUPS_REPO_URL" --assumeyes
test_success "repo create ($FEWUPS_REPO)" repo create --product="$FEWUPS_PRODUCT" --org="$TEST_ORG" --name="$FEWUPS_REPO" --url="$FEWUPS_REPO_URL"
test_success "filter create ($FILTER1)" filter create --org="$TEST_ORG" --name="$FILTER1" --description="description" --packages="package1, package2"
REPO_NAME=$(get_repo_name)
REPO_ID=$(get_repo_id)
