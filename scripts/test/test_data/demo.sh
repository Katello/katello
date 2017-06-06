#!/bin/bash
if [ $1 = "-i" ]; then
    echo "test data for ACME_Corporation"
    echo "environments: Library > dev > prod"
    echo "providers:    redhat, porkchop"
    echo "products:     fedora, zoo, fake"
    echo "repos:        lzap's fake repos, tstrachota's dummy repos"
    return
fi




$CMD environment create --name="dev" --org="ACME_Corporation" --prior="Library"
$CMD environment create --name="prod" --org="ACME_Corporation" --prior="dev"


$CMD product create --name="zoo" --provider="porkchop" --org="ACME_Corporation" --url="http://tstrachota.fedorapeople.org/dummy_repos/" --assumeyes
$CMD product create --name="fake" --provider="porkchop" --org="ACME_Corporation" --url="http://lzap.fedorapeople.org/fakerepos/fewupdates/" --assumeyes
$CMD product create --name="candlepin" --provider="porkchop" --org="ACME_Corporation" --url="http://repos.fedorapeople.org/repos/candlepin/candlepin/fedora-15/" --assumeyes


#(+)  [1] http://repos.fedorapeople.org/repos/candlepin/candlepin/fedora-15/x86_64
#(+)  [2] http://repos.fedorapeople.org/repos/candlepin/candlepin/fedora-15/SRPMS
#(+)  [3] http://repos.fedorapeople.org/repos/candlepin/candlepin/fedora-15/i386
