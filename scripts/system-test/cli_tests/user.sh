#!/bin/bash

header "User"

#testing user
test_success "user update" user update --username=$TEST_USER --password=password
test_success "user list" user list
test_success "user info" user info --username=$TEST_USER
