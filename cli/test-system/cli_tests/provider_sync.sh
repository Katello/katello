#!/bin/bash

header "Provider sync"

# testing provider sync
test_success "provider sync" provider synchronize --name="$YUM_PROVIDER" --org="$TEST_ORG"
