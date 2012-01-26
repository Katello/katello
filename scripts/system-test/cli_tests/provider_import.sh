#!/bin/bash

header "Provider import"

# importing manifest from our testing export
IMPORT_ORG="Import_Org_$RAND"
IMPORT_PROV="Red Hat"
test_success "org create" org create --name=$IMPORT_ORG
#the red hat provider is created automatically
test_failure "provider create" provider create --org="$IMPORT_ORG" --name="$IMPORT_PROV" --url="https://example.com/path/"
test_success "provider import_manifest" provider import_manifest --org="$IMPORT_ORG" --name="$IMPORT_PROV" --file=$TESTDIR/fake-manifest.zip --force
test_success "org delete" org delete --name=$IMPORT_ORG
