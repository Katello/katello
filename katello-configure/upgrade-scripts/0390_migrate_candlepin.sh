#!/bin/bash

#name: Migrate candlepin database
#apply: katello headpin
#run: always
#description:
#This step calls Candlepin cpdb utility to upgrade database schema
#in postgresql database to the latest version.

CANDLEPIN_HOME=${CANDLEPIN_HOME:-/usr/share/candlepin}

pushd $CANDLEPIN_HOME >/dev/null
./cpdb --update 2>&1
ret_code=$?
popd >/dev/null

exit $ret_code
