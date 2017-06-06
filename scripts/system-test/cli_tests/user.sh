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


# test default environment

TEST_USER2=${TEST_USER}2
test_success "user create with default environment" user create --username="$TEST_USER2" --email=email@example.com \
  --password=password --default_organization="$TEST_ORG" --default_environment="$TEST_ENV"
test_own_cmd_success "user has default environment" $CMD user info --username="$TEST_USER2" | grep "$TEST_ENV"
test_success "user default_environment_update" user update --username="$TEST_USER2" \
  --default_organization="$TEST_ORG" --default_environment="$TEST_ENV_2"
test_own_cmd_success "user has default environment" $CMD user info --username="$TEST_USER2" | grep "$TEST_ENV_2"
test_success "user default_environment_update" user update --username="$TEST_USER2" \
  --no_default_environment
test_own_cmd_success "user has default environment" $CMD user info --username="$TEST_USER2" | grep "$TEST_ENV_2"
test_success "user deletion" user delete --username="$TEST_USER2"

# test default locale

LOCALE_TEST_USER="locale_user_$RAND"
test_success "user create with locale" user create --username="$LOCALE_TEST_USER" \
  --password=password --email=$LOCALE_TEST_USER@somewhere.com --default_locale="fr"
test_success "user update with locale" user update --username="$LOCALE_TEST_USER" \
  --default_locale="pt-BR"
test_success "user delete with locale" user delete --username="$LOCALE_TEST_USER"
