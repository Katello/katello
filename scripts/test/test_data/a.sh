#!/bin/bash
if [ $1 = "-i" ]; then
    echo "test data for ACME_Corporation"
    echo "environments: Library > env_1 > env_2"
    echo "providers:    prov_a1, prov_a2 (2 products each)"
    echo "products:     prod_a1, prov_a2 (2 repos each), prod_a3, prod_a4"
    echo "repos:        lzap's fake repos, tstrachota's zoo repos"
    return
fi




$CMD environment create --name="env_1" --org="ACME_Corporation" --prior="Library"
$CMD environment create --name="env_2" --org="ACME_Corporation" --prior="env_1"

$CMD provider create --name="prov_a1" --org="ACME_Corporation" --type="custom"
$CMD provider create --name="prov_a2" --org="ACME_Corporation" --type="custom"

$CMD product create --name="prod_a1" --provider="prov_a1" --org="ACME_Corporation" --url="http://tstrachota.fedorapeople.org/dummy_repos/" --assumeyes
$CMD product create --name="prod_a2" --provider="prov_a1" --org="ACME_Corporation" --url="http://lzap.fedorapeople.org/fakerepos/" --assumeyes
#$CMD product create --name="prod_a3" --provider="prov_a2" --org="ACME_Corporation"
#$CMD product create --name="prod_a4" --provider="prov_a2" --org="ACME_Corporation"

# $CMD repo create --org="ACME_Corporation" --product="prod_a1" --url="http://lzap.fedorapeople.org/fakerepos/"         --name="repo_fake_a1" --assumeyes
# $CMD repo create --org="ACME_Corporation" --product="prod_a1" --url="http://tstrachota.fedorapeople.org/dummy_repos/" --name="repo_zoo_a1" --assumeyes
# $CMD repo create --org="ACME_Corporation" --product="prod_a2" --url="http://lzap.fedorapeople.org/fakerepos/"         --name="repo_fake_a2" --assumeyes
# $CMD repo create --org="ACME_Corporation" --product="prod_a2" --url="http://tstrachota.fedorapeople.org/dummy_repos/" --name="repo_zoo_a2" --assumeyes
# $CMD repo create --org="ACME_Corporation" --product="prod_a3" --url="http://lzap.fedorapeople.org/fakerepos/"         --name="repo_fake_a3" --assumeyes
# $CMD repo create --org="ACME_Corporation" --product="prod_a3" --url="http://tstrachota.fedorapeople.org/dummy_repos/" --name="repo_zoo_a3" --assumeyes
# $CMD repo create --org="ACME_Corporation" --product="prod_a4" --url="http://lzap.fedorapeople.org/fakerepos/"         --name="repo_fake_a4" --assumeyes
# $CMD repo create --org="ACME_Corporation" --product="prod_a4" --url="http://tstrachota.fedorapeople.org/dummy_repos/" --name="repo_zoo_a4" --assumeyes


