#!/bin/bash

#name: Migrate candlepin database
#apply: katello headpin
#run: always
#description:
#This step calls Candlepin cpdb utility to upgrade database schema
#in postgresql database to the latest version.

CANDLEPIN_HOME=${CANDLEPIN_HOME:-/usr/share/candlepin}
CPDB_NAME=$(katello-configure-answer candlepin_db_name)
CPDB_USER=$(katello-configure-answer candlepin_db_user)
CPDB_PASS=$(katello-configure-answer candlepin_db_password)

pushd $CANDLEPIN_HOME >/dev/null
./cpdb --update 2>&1 --database=$CPDB_NAME --user=$CPDB_USER --password=$CPDB_PASS
ret_code=$?
popd >/dev/null

exit $ret_code
