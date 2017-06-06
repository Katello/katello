#!/bin/bash

header "User Role"

ROLE_NAME="role_$RAND"
ROLE_NAME_2="role_$RAND_2"
#testing user roles
test_success "user_role create" user_role create --name="$ROLE_NAME" --description="description of the role"
test_success "user_role list" user_role list
test_success "user_role info" user_role info --name="$ROLE_NAME"
test_success "user_role update" user_role update --name="$ROLE_NAME" --new_name="$ROLE_NAME_2" --description="new description of the role"
test_failure "test if the name changed" user_role info --name="$ROLE_NAME"
test_success "user_role delete" user_role delete --name="$ROLE_NAME_2"
