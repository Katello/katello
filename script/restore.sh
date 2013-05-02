#!/bin/bash -e
BDIR=$(readlink -f "$1")
cd $BDIR

#shut everything down
katello-service stop

#extract files
tar --selinux -xzvf config_files.tar.gz -C /
tar --selinux -xzvf elastic_data.tar.gz -C /
tar --selinux -xvf pulp_data.tar -C /

#restore dbs
service postgresql start
sleep 5
dropdb -U postgres katelloschema
dropdb -U postgres candlepin

pg_restore -U postgres -C -d postgres $BDIR/katello.dump
pg_restore -U postgres -C -d postgres $BDIR/candlepin.dump

service mongod start
sleep 5
echo 'db.dropDatabase();' | mongo pulp_database

mongorestore --host localhost mongo_dump/pulp_database/

# Restart services
katello-service start
