#!/bin/bash

header "Client"

KEY="key_$RAND"
VALUE="val_$RAND"

test_success "client remember"      client remember --option="$KEY" --value="$VALUE"
test_success "client saved_options" client saved_options
test_success "client_forget"        client forget --option="$KEY"
