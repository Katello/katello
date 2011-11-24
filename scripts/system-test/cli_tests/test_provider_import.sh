#!/bin/bash

header "Provider import"

# importing manifest from our testing export
IMPORT_ORG="Import_Org_$RAND"
IMPORT_PROV="Red Hat"
test_success "org create" org create --name=$IMPORT_ORG
#the red hat provider is created automatically
#test_success "provider import_manifest" provider import_manifest --org="$IMPORT_ORG" --name="$IMPORT_PROV" --file=$TESTDIR/../../../manifests/stageManifest06October2011.zip
#test_success "provider import_manifest" provider import_manifest --org="$IMPORT_ORG" --name="$IMPORT_PROV" --file=$TESTDIR/../../../manifests/fte2NovemberSamTest.zip
#test_success "provider import_manifest" provider import_manifest --org="$IMPORT_ORG" --name="$IMPORT_PROV" --file=$TESTDIR/../../../manifests/fte2NovemberSamTest2.zip
test_success "provider import_manifest" provider import_manifest --org="$IMPORT_ORG" --name="$IMPORT_PROV" --file=$TESTDIR/../../../manifests/stageSamTest20Nov2011.zip
#test_success "provider import_manifest" provider import_manifest --org="$IMPORT_ORG" --name="$IMPORT_PROV" --file=$TESTDIR/../../../manifests/stageSamTestSimple20Nov2011.zip
#test_success "org delete" org delete --name=$IMPORT_ORG
