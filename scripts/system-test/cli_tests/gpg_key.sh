#!/bin/bash

header "GPG Key"

GPG_KEY_NAME="Dummy-Package-Generator"
GPG_KEY_NAME_2="Another-Dummy-Package-Generator"
GPG_KEY_NAME_3="Renamed-Dummy-Package-Generator"
GPG_KEY_FILE="$TESTDIR/RPM-GPG-KEY-dummy-packages-generator"
GPG_KEY_CONTENT=`cat $GPG_KEY_FILE`

test_success "gpg create from file" gpg_key create --name="$GPG_KEY_NAME" --org="$TEST_ORG" --file="$GPG_KEY_FILE"
test_own_cmd_success "gpg create from input" echo "$GPG_KEY_CONTENT" | $CMD gpg_key create --name="$GPG_KEY_NAME_2" --org="$TEST_ORG" &>/dev/null

test_success "gpg list" gpg_key list --org="$TEST_ORG"
test_success "gpg info" gpg_key info --name="$GPG_KEY_NAME" --org="$TEST_ORG"

test_success "gpg update name" gpg_key update --name="$GPG_KEY_NAME_2" --org="$TEST_ORG" --new_name "$GPG_KEY_NAME_3"
test_success "gpg update content with file" gpg_key update --name="$GPG_KEY_NAME" --org="$TEST_ORG" --file "$GPG_KEY_FILE"
test_own_cmd_success "gpg update from input" echo "$GPG_KEY_CONTENT" | $CMD gpg_key update --name="$GPG_KEY_NAME" --org="$TEST_ORG" --new_content &>/dev/null

GPG_PRODUCT="GPG-product-$RAND"
GPG_REPO="GPG-repo-$RAND"
GPG_REPO_2="GPG-repo-2-$RAND"
GPG_REPO_URL="http://inecas.fedorapeople.org/fakerepos/zoo"

test_success "create a product with gpg" product create --provider "$YUM_PROVIDER" --org "$TEST_ORG" --name "$GPG_PRODUCT" --assumeyes --gpgkey "$GPG_KEY_NAME"
test_success "create a repo with gpg" repo create --product="$GPG_PRODUCT" --org="$TEST_ORG" --name="$GPG_REPO" --url="$GPG_REPO_URL" --gpgkey "$GPG_KEY_NAME"
test_success "create a repo without gpg" repo create --product="$GPG_PRODUCT" --org="$TEST_ORG" --name="$GPG_REPO_2" --url="$GPG_REPO_URL" --nogpgkey

test_success "add gpg to a repo" repo update --product="$GPG_PRODUCT" --org="$TEST_ORG" --name="$GPG_REPO_2" --gpgkey "$GPG_KEY_NAME"
test_success "update a product's gpg" product update --org "$TEST_ORG" --name "$GPG_PRODUCT" --gpgkey "$GPG_KEY_NAME_3"
test_success "update a product's gpg recursively" product update --org "$TEST_ORG" --name "$GPG_PRODUCT" --gpgkey "$GPG_KEY_NAME_3" --recursive
test_success "update a repo's gpg" repo update --product="$GPG_PRODUCT" --org="$TEST_ORG" --name="$GPG_REPO" --gpgkey "$GPG_KEY_NAME"
test_success "gpg repo delete" repo delete --product="$GPG_PRODUCT" --org="$TEST_ORG" --name="$GPG_REPO_2"

test_success "remove a products's gpg" product update --org "$TEST_ORG" --name "$GPG_PRODUCT" --nogpgkey
test_success "remove a product's gpg recursively" product update --org "$TEST_ORG" --name "$GPG_PRODUCT" --nogpgkey --recursive
test_success "remove a repo's gpg"  repo update --product="$GPG_PRODUCT" --org="$TEST_ORG" --name="$GPG_REPO" --nogpgkey

test_success "gpg repo delete" repo delete --product="$GPG_PRODUCT" --org="$TEST_ORG" --name="$GPG_REPO"
test_success "gpg product delete" product delete --org="$TEST_ORG" --name="$GPG_PRODUCT"

test_success "gpg delete" gpg_key delete --name="$GPG_KEY_NAME" --org="$TEST_ORG"
test_success "gpg delete" gpg_key delete --name="$GPG_KEY_NAME_3" --org="$TEST_ORG"
