#!/bin/bash


# testing systems
SYSTEM_NAME_ADMIN="admin_system_$RAND"
SYSTEM_NAME_USER="user_system_$RAND"
ACTIVATION_KEY_NAME_1="activation_key_1_$RAND"
ACTIVATION_KEY_NAME_2="activation_key_2_$RAND"
ACTIVATION_KEY_NAME_3="activation_key_3_$RAND"

test "system register as admin" system register --name="$SYSTEM_NAME_ADMIN" --org="$FIRST_ORG" --environment="$TEST_ENV"
skip_test "system register as $TEST_USER" "none" -u $TEST_USER -p password system register --name="$SYSTEM_NAME_USER" --org="$FIRST_ORG" --environment="$TEST_ENV"
test "system info" system info --name="$SYSTEM_NAME_ADMIN" --org="$FIRST_ORG"
skip_test "system unregister" "none" system unregister --name="$SYSTEM_NAME_ADMIN" --org="$FIRST_ORG"
test "system list" system list --org="$FIRST_ORG"

test "activation key create" activation_key create --name="$ACTIVATION_KEY_NAME_1" --description="key description" --environment="$TEST_ENV" --org="$FIRST_ORG"
test "activation key create" activation_key create --name="$ACTIVATION_KEY_NAME_2" --description="key description" --environment="$TEST_ENV" --org="$FIRST_ORG"
test "activation key create" activation_key create --name="$ACTIVATION_KEY_NAME_3" --description="key description" --environment="$TEST_ENV" --org="$FIRST_ORG"
test "system register with activation key" system register --name="$SYSTEM_NAME_ADMIN" --org="$FIRST_ORG" --environment="$TEST_ENV" --activationkey="$ACTIVATION_KEY_NAME_1,$ACTIVATION_KEY_NAME_2" --activationkey="$ACTIVATION_KEY_NAME_3"

