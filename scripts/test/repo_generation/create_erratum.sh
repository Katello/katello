#!/bin/bash


if [ $# -ne 5 ] && [ $# -ne 6 ]; then
  echo "Script for generating dummy erratum"
  echo "takes 4 params:"
  echo "  1st - pulp id of the repository"
  echo "  2nd - id of the erratum"
  echo "  3rd - type of the erratum (enhancement, bugfix, security)"
  echo "  4th - title of the erratum"
  echo "  5th - comma separated list of affected packages"
  echo "  6th - path to affected packages (optional)"
  exit
fi


repo_id=$1
erratum_id=$2
erratum_type=$3
title=$4
packages=$5
issued=`date +"%Y-%m-%d %T"`

get-rpm-attr() {
    rpm -qpi $1 | egrep "^$2" | sed -e 's/[^:]*:\ \([^\ ]*\).*/\1/'
}

if [ $# -gt 5 ]; then
    packages_path=$6
else
    packages_path="./"
fi


rm ./erratum.tmp.csv
touch ./erratum.tmp.csv
for filename in `echo $packages | sed "s/,/ /g"`; do
    p="$packages_path$filename"
    echo $p

    name=`get-rpm-attr $p Name`
    version=`get-rpm-attr $p Version`
    release=`get-rpm-attr $p Release`
    arch=`get-rpm-attr $p Architecture`
    md5sum=`md5sum $p | awk '{print $1}'`

    echo $name
    echo "$name,$version,$release,0,$arch,$filename,$md5sum,md5,http://www.fedoraproject.org" >> ./erratum.tmp.csv
done


pulp-admin errata create --id $erratum_id --title "$title" --version 1 --release 1 \
--type $erratum_type --issued "$issued" --status stable --fromstr "errata@redhat.com" --effected-packages ./erratum.tmp.csv
pulp-admin repo add_errata --id $repo_id --errata $erratum_id -y

#rm ./erratum.tmp.csv
