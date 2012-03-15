#!/bin/bash

header "Permission"

ROLE_NAME="tmp_permission_role_$RAND"
ENV_PERMISSION_NAME="env_perm_$RAND"
ENV_PERMISSION_NAME_2=$ENV_PERMISSION_NAME"_2"
ALL_PERMISSION_NAME="all_perm_$RAND"
ALL_PERMISSION_NAME_2=$ALL_PERMISSION_NAME"_2"

#create user role for testing permissions
test_success "user_role create" user_role create --name="$ROLE_NAME"


test_success "permission available_verbs" permission available_verbs
test_success "permission create 'access everything'" permission create --user_role="$ROLE_NAME" --name="$ALL_PERMISSION_NAME" --scope="all"
test_success "permission create 'access everything in org'" permission create --user_role="$ROLE_NAME" --name="$ALL_PERMISSION_NAME_2" --scope="all" --org="$TEST_ORG"
test_success "permission create with verbs" permission create --user_role="$ROLE_NAME" --name="$ENV_PERMISSION_NAME" --scope="environments" --verbs="read_contents"
test_success "permission create with verbs & tags" permission create --user_role="$ROLE_NAME" --name="$ENV_PERMISSION_NAME_2" --scope="environments" --verbs="read_contents" --tags="Library" --org="$TEST_ORG"
test_success "permission list" permission list --user_role="$ROLE_NAME"
test_success "permission delete" permission delete --user_role="$ROLE_NAME" --name="$ALL_PERMISSION_NAME"
test_success "permission delete" permission delete --user_role="$ROLE_NAME" --name="$ALL_PERMISSION_NAME_2"
test_success "permission delete" permission delete --user_role="$ROLE_NAME" --name="$ENV_PERMISSION_NAME"
test_success "permission delete" permission delete --user_role="$ROLE_NAME" --name="$ENV_PERMISSION_NAME_2"
