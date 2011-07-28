#!/bin/bash

DIR="$( cd "$( dirname "$0" )" && pwd )"

# testing provider sync
test "provider sync" provider synchronize --name="$YUM_PROVIDER" --org="$FIRST_ORG"

# importing manifest from our testing export
#testing organization
IMPORT_ORG="Import_Org_$RAND"
IMPORT_PROV="Import_Prov_$RAND"
test "org create" org create --name=$IMPORT_ORG
test "provider create" provider create --org="$IMPORT_ORG" --name="$IMPORT_PROV" --type=redhat --url="https://example.com/path/"
test "provider import_manifest" provider import_manifest --org="$IMPORT_ORG" --name="$IMPORT_PROV" --file=$DIR/export-manifest.zip
test "provider delete" provider delete --org="$IMPORT_ORG" --name="$IMPORT_PROV"
test "org delete" org delete --name=$IMPORT_ORG
