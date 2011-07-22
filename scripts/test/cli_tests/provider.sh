#!/bin/bash


#testing provider sync
test "provider sync" provider sync --name="$YUM_PROVIDER" --org="$FIRST_ORG"
