#!/bin/bash
if [ $1 = "-i" ]; then
    echo "test data for ACME_Corporation, changeset for env_1"
    return
fi


$CMD changeset create --env="env_1" --org="ACME_Corporation" --name="TMP"
$CMD changeset update --env="env_1" --org="ACME_Corporation" --name="TMP" --add_product="prod_a1"
$CMD changeset promote --env="env_1" --org="ACME_Corporation" --name="TMP"

$CMD changeset create --env="env_1" --org="ACME_Corporation" --name="XXX"
$CMD changeset update --env="env_1" --org="ACME_Corporation" --name="XXX" --from_product="prod_a1" --add_package="cheetah"
$CMD changeset update --env="env_1" --org="ACME_Corporation" --name="XXX" --from_product="prod_a1" --add_repo="repo_zoo_a1_dummy_repos_zoo"
$CMD changeset update --env="env_1" --org="ACME_Corporation" --name="XXX" --from_product="prod_a1" --add_erratum="RHEA-2010:9999"


$CMD changeset create --env="env_1" --org="ACME_Corporation" --name="YYY"
# $CMD changeset update --env="env_1" --org="ACME_Corporation" --name="YYY" --add_product="prod_a1" --from_product="prod_a1" --add_package="cheetah" --add_repo="repo_zoo_a1_dummy_repos_zoo" --add_erratum="RHEA-2010:9999"

$CMD changeset create --env="env_1" --org="ACME_Corporation" --name="ZZZ"
# $CMD changeset update --env="env_1" --org="ACME_Corporation" --name="ZZZ" --add_package="cheetah" --add_repo="repo_zoo_a1_dummy_repos_zoo" --add_erratum="RHEA-2010:9999"