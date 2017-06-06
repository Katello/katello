#!/bin/bash

header "Activation keys"

ACTIVATION_KEY_NAME="activation_key_$RAND"
test_success "activation key create" activation_key create --name="$ACTIVATION_KEY_NAME" --description="key description" --environment="$TEST_ENV" --org="$TEST_ORG"
test_success "list activation keys by environment" activation_key list --environment="$TEST_ENV" --org="$TEST_ORG"
test_success "list activation keys by organization" activation_key list --environment="$TEST_ENV" --org="$TEST_ORG"
test_success "show activation key" activation_key info --org="$TEST_ORG" --name="$ACTIVATION_KEY_NAME"
test_success "delete activation key" activation_key delete --org="$TEST_ORG" --name="$ACTIVATION_KEY_NAME"
