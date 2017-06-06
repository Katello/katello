#!/bin/bash

if [ $# -ne 3 ]; then
  echo "Script for generating dummy errata from a definition file"
  echo "takes 3 params:"
  echo "  1st - pulp id of the repository"
  echo "  2nd - path to file with errata definition"
  echo "  3rd - path to the s directory with the packages included in errata"
  exit
fi



repo_id=$1
errata_list=$2
packages_dir=$3

cat $errata_list | while read line; do

    echo "./create_erratum.sh $repo_id $line $packages_dir"
    ./create_erratum.sh $repo_id $line $packages_dir
done
