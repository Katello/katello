#!/bin/bash

#name: Update Candlepin
#apply: katello headpin
#description:
#Updates Candlepin database schema to the latest version

CANDLEPIN_HOME=${CANDLEPIN_HOME:-/usr/share/candlepin}

# remove hornetq extraneous files for certain candlepin upgrades
rm -rf /var/lib/candlepin/hornetq/bindings
rm -rf /var/lib/candlepin/hornetq/journal
rm -rf /var/lib/candlepin/hornetq/largemsgs

pushd $CANDLEPIN_HOME >/dev/null
./cpdb --update 2>&1
ret_code=$?
popd >/dev/null

exit $ret_code
