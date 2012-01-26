#!/bin/bash
if [ $1 = "-i" ]; then
    echo "test data for ACME_Corporation"
    echo "environments: Library"
    echo "providers:    prov_a1"
    echo "products:     prod_a1"
    echo "repos:        tstrachota's dummy repo"
    return
fi

PROD_NAME="dummy_prod"
PROV_NAME="dummy_prov"
$CMD provider create --name="$PROV_NAME" --org="ACME_Corporation" --type="custom"

$CMD product create --name="$PROD_NAME" --provider="$PROV_NAME" --org="ACME_Corporation" --url="http://tstrachota.fedorapeople.org/dummy_repos/" --assumeyes

#$CMD repo create --org="ACME_Corporation" --product="prod_a1" --url="http://lzap.fedorapeople.org/fakerepos/"         --name="repo_fake_a1" --assumeyes
#$CMD repo create --org="ACME_Corporation" --product="prod_a1" --url="http://tstrachota.fedorapeople.org/dummy_repos/" --name="repo_zoo_a1" --assumeyes



