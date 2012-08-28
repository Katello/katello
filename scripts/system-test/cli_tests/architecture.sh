#!/bin/bash

header "Architectures"

ARCH_NAME="a_$RAND"
NEW_ARCH_NAME="b_$RAND"

#testing architectures
test_success "architecture create" architecture create --name="$ARCH_NAME"
test_success "architecture info" architecture info --name="$ARCH_NAME"
test_success "architecture update" architecture update --name="$ARCH_NAME" --new_name="$NEW_ARCH_NAME"
test_success "architecture list" architecture list
test_failure "architecture try to delete old name" architecture delete --name="$ARCH_NAME"
test_success "architecture delete" architecture delete --name="$NEW_ARCH_NAME"

