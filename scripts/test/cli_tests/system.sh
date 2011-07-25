#!/bin/bash


# testing systems
SYSTEM_NAME_ADMIN="admin_system_$RAND"
SYSTEM_NAME_USER="user_system_$RAND"
test "system register as admin" system register --name="$SYSTEM_NAME_ADMIN" --org="$FIRST_ORG" --environment="$TEST_ENV"
skip_test "system register as $TEST_USER" "none" -u $TEST_USER -p password system register --name="$SYSTEM_NAME_USER" --org="$FIRST_ORG" --environment="$TEST_ENV"
test "system info" system info --name="$SYSTEM_NAME_ADMIN" --org="$FIRST_ORG"
skip_test "system unregister" "none" system unregister --name="$SYSTEM_NAME_ADMIN" --org="$FIRST_ORG"
test "system list" system list --org="$FIRST_ORG"

