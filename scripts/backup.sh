#!/bin/bash
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

BDIR=$(readlink -f "$1")
mkdir -p $BDIR
cd $BDIR

echo "Backing up config files... "
tar --selinux -czvf config_files.tar.gz \
/etc/katello \
/etc/elasticsearch \
/etc/candlepin \
/etc/pulp \
/etc/grinder \
/etc/pki/katello \
/etc/pki/pulp \
/etc/qpidd.conf \
/etc/sysconfig/katello \
/etc/sysconfig/elasticsearch \
/root/ssl-build \
/var/www/html/pub/*
echo "Done."

echo "Backing up Elastic Search data... "
tar --selinux -czvf elastic_data.tar.gz /var/lib/elasticsearch
echo "Done."

echo "Backing up Pulp data... "
PULP_TAR=pulp_data.tar
CUR_STATE=`find /var/lib/pulp -printf '%T@\n' | md5sum`
#should probably put a count limit on this to avoid possible infinite loop
until [ "$CUR_STATE" == "$PREV_STATE" ]; do
    rm -f $PULP_TAR
    tar --selinux -cvf $PULP_TAR /var/lib/pulp /var/www/pub
    PREV_STATE=$CUR_STATE
    CUR_STATE=`find /var/lib/pulp -printf '%T@\n' | md5sum`
done
echo "Done."

echo "Backing up postgres db... "
pg_dump -U postgres -Fc ${KATELLO_SCHEMA:-katelloschema} > $BDIR/katello.dump
pg_dump -U postgres -Fc ${CANDLEPIN_SCHEMA:-candlepin} > $BDIR/candlepin.dump
echo "Done."

echo "Backing up mongo db... "
mongodump --host localhost --out mongo_dump
echo "Done."

echo "Backup complete in $BDIR"
