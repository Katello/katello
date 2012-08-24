#!/bin/bash

header "Domains"

DOMAIN_NAME="a_$RAND"
NEW_DOMAIN_NAME="b_$RAND"

test_success "domain create" domain create --name="$DOMAIN_NAME"
test_success "domain info" domain info --name="$DOMAIN_NAME"
test_success "domain update" domain update --name="$DOMAIN_NAME" --new_name="$NEW_DOMAIN_NAME"
test_success "domain list" domain list
test_failure "domain try to delete old name" domain delete --name="$DOMAIN_NAME"
test_success "domain delete" domain delete --name="$NEW_DOMAIN_NAME"
