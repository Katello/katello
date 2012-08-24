#!/bin/bash

header "Config Templates"

NAME="a_$RAND"
NEW_NAME="b_$RAND"
SNIPPET_NAME="c_$RAND"

test_failure "config_template try create not valid" config_template create --name="$NAME"
test_success "config_template create" config_template create --name="$NAME" --template="test template" --template_kind_id=1
test_success "config_template create snippet" config_template create --name="$SNIPPET_NAME" --template="test snippet" --snippet=true
test_success "config_template info" config_template info --name="$NAME"
test_success "config_template update name" config_template update --name="$NAME" --new_name="$NEW_NAME"
test_success "config_template update template" config_template update --name="$NEW_NAME" --template="new test template"
test_success "config_template list" config_template list
test_failure "config_template try to delete old name" config_template delete --name="$NAME"
test_success "config_template delete" config_template delete --name="$NEW_NAME"
test_success "config_template delete snippet" config_template delete --name="$SNIPPET_NAME"
