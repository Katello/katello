#!/bin/bash

header "GPG Key"

GPG_KEY_NAME="Dummy-Package-Generator"
GPG_KEY_NAME_2="Another-Dummy-Package-Generator"
GPG_KEY_NAME_3="Renamed-Dummy-Package-Generator"
GPG_KEY_FILE="$TESTDIR/RPM-GPG-KEY-dummy-packages-generator"
GPG_KEY_CONTENT=`cat $GPG_KEY_FILE`

test_success "gpg create from file" gpg_key create --name="$GPG_KEY_NAME" --org="$TEST_ORG" --file="$GPG_KEY_FILE"
test_own_cmd_success "gpg create from input" echo $GPG_KEY_CONTENT | $CMD gpg_key create --name="$GPG_KEY_NAME_2" --org="$TEST_ORG" &>/dev/null

test_success "gpg list" gpg_key list --org="$TEST_ORG"
test_success "gpg info" gpg_key info --name="$GPG_KEY_NAME" --org="$TEST_ORG"

test_success "gpg update name" gpg_key update --name="$GPG_KEY_NAME_2" --org="$TEST_ORG" --new_name $GPG_KEY_NAME_3
test_success "gpg update content with file" gpg_key update --name="$GPG_KEY_NAME" --org="$TEST_ORG" --file $GPG_KEY_FILE
test_own_cmd_success "gpg update from input" echo $GPG_KEY_CONTENT | $CMD gpg_key update --name="$GPG_KEY_NAME" --org="$TEST_ORG" --new_content &>/dev/null

test_success "gpg delete" gpg_key delete --name="$GPG_KEY_NAME" --org="$TEST_ORG"
test_success "gpg delete" gpg_key delete --name="$GPG_KEY_NAME_3" --org="$TEST_ORG"
