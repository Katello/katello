#!/bin/bash

header "User"

ROLE_NAME="tmp_user_role_$RAND"

#testing user
test_success "user update" user update --username="$TEST_USER" --password=password
test_success "user list" user list
test_success "user info" user info --username="$TEST_USER"


#test role assignment
test_success "user_role create" user_role create --name="$ROLE_NAME"
test_success "user assign_role" user assign_role --username="$TEST_USER" --role="$ROLE_NAME"
test_success "user unassign_role" user unassign_role --username="$TEST_USER" --role="$ROLE_NAME"
