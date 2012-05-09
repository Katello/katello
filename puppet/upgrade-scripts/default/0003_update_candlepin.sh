#!/bin/bash

#name: Update Candlepin
#apply: katello headpin
#description:
#Updates Candlepin database schema to the latest version

CANDLEPIN_HOME=${CANDLEPIN_HOME:-/usr/share/candlepin}

pushd $CANDLEPIN_HOME >/dev/null
./cpdb --update 2>&1
ret_code=$?
popd >/dev/null

exit $ret_code
