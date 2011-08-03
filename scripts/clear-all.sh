#!/bin/bash


KATELLO=$1


MODE=$2
if [ "$2" == "" ]; then
  MODE="development"
fi


if [ ! -d "$KATELLO" ]
then
  echo "useage:sh clear-all.sh <katello_git>"
  exit 0
fi



echo "Resetting $1 for $MODE"
if [ -d $KATELLO/src ]; then
  KATELLO="$KATELLO/src/"
fi

# check rails server
UP=`lsof -i :3000 | grep LISTEN`
if [ $? -eq 0 ]
then
  echo "Kill your Rails server and restart"
  exit 0
fi


#detect non-local candlepin
LOCAL_CP=1
grep '/candlepin' /etc/katello/katello.yml | grep -v "#" | grep url | grep localhost > /dev/null 
if [ $?  != 0 ]; then
  LOCAL_CP=0
fi


LOCAL_PULP=1
grep 'pulp' /etc/katello/katello.yml | grep -v '#' | grep url | grep localhost > /dev/null
if [ $?  != 0 ]; then
  LOCAL_PULP=0
fi

if [ $LOCAL_PULP == 1 ]; then
 # clear pulp data
 echo "clearing pulp..."

 #figure out clear-mongo.js path
 # if pointing to git, this works
 MONGO_CLEAR=$KATELLO/scripts/clear-mongo.js
 if [ ! -f "$MONGO_CLEAR" ]; then
  #not pointing to git, so must be rpm, try running from 
  # wherever this script is running from
  MONGO_CLEAR="`dirname $0`/clear-mongo.js" 
 fi

 if [ ! -f "$MONGO_CLEAR" ]; then
   echo "Cannot locate clear-mongo.js :( "
   echo "looked in $KATELLO/scripts/ and `dirname $0`"
   echo "If you are running from a symbolic link, copy clear-mongo.js to `dirname $0`"
   exit -1
 fi

 mongo pulp_database $MONGO_CLEAR
 if [ $? != 0 ]; then
   echo "Failed to reset pulp!"
   exit -1
 fi
 sudo service pulp-server init
 echo "wiping pulp repos..."
 sudo rm /var/lib/pulp/repos/* -rf
 sudo rm /var/lib/pulp/published/repos/* -rf
 sudo service httpd restart

fi


if [ $LOCAL_CP == 1 ]; then
 # clear candlepin
 echo "clearing candlepin..."
 sudo service postgresql restart
 sudo /usr/share/candlepin/cpsetup -s
 if [ $? != 0 ]; then
   echo "Failed to reset candlepin!"
   exit -1
 fi
fi

if [ $LOCAL_PULP == 1 ] && [ $LOCAL_CP == 1 ]; then
  sudo $KATELLO/script/reset-oauth
  sudo SYSTEMCTL_SKIP_REDIRECT=1 service pulp-server restart
fi
if [ $LOCAL_CP == 1 ]; then
  sudo service tomcat6 restart
fi

cd $KATELLO

RAILS_ENV=$MODE rake setup --trace

if [ "$KATELLO" == "/usr/lib64/katello" ] || [ "$KATELLO" == "/usr/lib64/katello/" ]; then
  echo "Resetting permissions in $KATELLO"
  sudo chown -R katello:katello $KATELLO
  sudo chown -R katello:katello /var/lib/katello/
fi

if [ $LOCAL_CP == 0 ]; then
  echo "
==================================
WARNING! WARNING! WARNING! WARNING!
Candlepin is not being run locally, 
please run /usr/share/candlepin/cp-setup manually
"
fi

if [ $LOCAL_PULP == 0 ]; then
  echo "
==================================
WARNING! WARNING! WARNING! WARNING!
Pulp is not being run locally, 
Please clear pulp's db manually
"

fi


