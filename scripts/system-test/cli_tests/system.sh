#!/bin/bash

header "System"

# testing systems
SYSTEM_NAME_ADMIN="admin_system_$PLAIN_RAND"
SYSTEM_NAME_ADMIN_2=$SYSTEM_NAME_ADMIN"_2"
SYSTEM_NAME_USER="user_system_$RAND"
ACTIVATION_KEY_NAME_1="activation_key_1_$RAND"
ACTIVATION_KEY_NAME_2="activation_key_2_$RAND"
ACTIVATION_KEY_NAME_3="activation_key_3_$RAND"
SYS_GROUP_NAME="system_group_$RAND"

test_success "system register as admin" system register --name="$SYSTEM_NAME_ADMIN" --org="$TEST_ORG" --environment="$TEST_ENV"
skip_test_success "system register as $TEST_USER" "none" -u "$TEST_USER" -p password system register --name="$SYSTEM_NAME_USER" --org="$TEST_ORG" --environment="$TEST_ENV"
test_success "system info" system info --name="$SYSTEM_NAME_ADMIN" --org="$TEST_ORG"
UUID=$($CMD system info --name="$SYSTEM_NAME_ADMIN" --org="$TEST_ORG" | grep -Eo '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}' | head -n1)
test_success "system info uuid" system info --uuid="$UUID" --org="$TEST_ORG"
test_success "system releases" system releases --name="$SYSTEM_NAME_ADMIN" --org="$TEST_ORG"
test_success "system releases uuid" system releases --uuid="$UUID" --org="$TEST_ORG"
test_success "system list" system list --org="$TEST_ORG"

test_success "system group create" system_group create --name $SYS_GROUP_NAME --org="$TEST_ORG"
test_failure "system add fake to group" system_group add_systems --system_uuids "dont_exist" --name "$SYS_GROUP_NAME" --org "$TEST_ORG"
test_success "system add group" system add_to_groups --name $SYSTEM_NAME_ADMIN --system_groups $SYS_GROUP_NAME --org="$TEST_ORG"
test_success "system remove group" system remove_from_groups --name $SYSTEM_NAME_ADMIN --system_groups $SYS_GROUP_NAME --org="$TEST_ORG"
test_success "system add group uuid" system add_to_groups --uuid $UUID --system_groups $SYS_GROUP_NAME --org="$TEST_ORG"
test_success "system remove group uuid" system remove_from_groups --uuid $UUID --system_groups $SYS_GROUP_NAME --org="$TEST_ORG"
test_success "system group delete " system_group delete --name $SYS_GROUP_NAME --org="$TEST_ORG"

test_success "system subscriptions" system subscriptions --org="$TEST_ORG" --name="$SYSTEM_NAME_ADMIN" --available
test_success "system subscriptions uuid" system subscriptions --org="$TEST_ORG" --uuid="$UUID" --available
POOL_ID=$($CMD system subscriptions --org="$TEST_ORG" --name="$SYSTEM_NAME_ADMIN" --available -v | grep ID | grep -oE '[a-z0-9]{32}' | head -n1)
test_success "system subscribe" system subscribe --org="$TEST_ORG" --name="$SYSTEM_NAME_ADMIN" --pool="$POOL_ID"
test_success "system unsubscribe" system unsubscribe --org="$TEST_ORG" --name="$SYSTEM_NAME_ADMIN" --all
test_success "system subscribe" system subscribe --org="$TEST_ORG" --uuid="$UUID" --pool="$POOL_ID"
test_success "system list for a pool id" system list --org="$TEST_ORG" --pool="$POOL_ID"
test_success "system list for unknown pool id" system list --org="$TEST_ORG" --pool="unknown_pool_id"

test_success "system packages" system packages --org="$TEST_ORG" --name="$SYSTEM_NAME_ADMIN"
test_success "system packages uuid" system packages --org="$TEST_ORG" --uuid="$UUID"
test_success "system facts" system facts --org="$TEST_ORG" --name="$SYSTEM_NAME_ADMIN"
test_success "system facts uuid" system facts --org="$TEST_ORG" --uuid="$UUID"
test_success "system update name" system update --org="$TEST_ORG" --name="$SYSTEM_NAME_ADMIN" --new_name="$SYSTEM_NAME_ADMIN_2"
test_success "system update name uuid" system update --org="$TEST_ORG" --uuid="$UUID" --new_name="$SYSTEM_NAME_ADMIN"
test_success "system update description" system update --org="$TEST_ORG" --name="$SYSTEM_NAME_ADMIN" --description="This is a description of a system. It's a great description"
test_success "system update location" system update --org="$TEST_ORG" --name="$SYSTEM_NAME_ADMIN" --location="The Grid"
test_success "system update release" system update --org="$TEST_ORG" --name="$SYSTEM_NAME_ADMIN" --release="6.2"
test_success "system update environment" system update --org="$TEST_ORG" --name="$SYSTEM_NAME_ADMIN" --new_environment="$TEST_ENV_2"
test_success "system unregister uuid" system unregister --uuid="$UUID" --org="$TEST_ORG"

test_success "activation key create" activation_key create --name="$ACTIVATION_KEY_NAME_1" --description="key description" --environment="$TEST_ENV" --org="$TEST_ORG"
test_success "activation key create" activation_key create --name="$ACTIVATION_KEY_NAME_2" --description="key description" --environment="$TEST_ENV" --org="$TEST_ORG"
test_success "system register with activation key" system register --name="$SYSTEM_NAME_ADMIN" --org="$TEST_ORG" --activationkey="$ACTIVATION_KEY_NAME_1"
test_success "system unregister" system unregister --name="$SYSTEM_NAME_ADMIN" --org="$TEST_ORG"
test_success "system register with activation keys" system register --name="$SYSTEM_NAME_ADMIN" --org="$TEST_ORG" --activationkey="$ACTIVATION_KEY_NAME_1,$ACTIVATION_KEY_NAME_2"
test_success "system unregister" system unregister --name="$SYSTEM_NAME_ADMIN" --org="$TEST_ORG"

test_success "limited ak create" activation_key create --name="$ACTIVATION_KEY_NAME_3" --description="key description" --environment="$TEST_ENV" --org="$TEST_ORG" --limit=1
test_success "system register with limited ak" system register --name="$SYSTEM_NAME_ADMIN" --org="$TEST_ORG" --activationkey="$ACTIVATION_KEY_NAME_3"
test_failure "system register with limited ak" system register --name="$SYSTEM_NAME_ADMIN_2" --org="$TEST_ORG" --activationkey="$ACTIVATION_KEY_NAME_3"
test_success "system unregister" system unregister --name="$SYSTEM_NAME_ADMIN" --org="$TEST_ORG"
test_success "system add custom_info" system custom_info add --org="$TEST_ORG" --name="$SYSTEM_NAME_ADMIN" --keyname="asset_tag" --value="1234"
test_success "system add_custom_info without a value" system custom_info add --org="$TEST_ORG" --name="$SYSTEM_NAME_ADMIN" --keyname="hello world"
test_success "system update custom_info" system custom_info update --org="$TEST_ORG" --name="$SYSTEM_NAME_ADMIN" --keyname="hello world" --value="hello system-tests"
test_success "system remove custom_info" system custom_info remove --org="$TEST_ORG" --name="$SYSTEM_NAME_ADMIN" --keyname="hello world"
