#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Script for generating fake repositories from definition files"
  echo "takes 2 params:"
  echo "  1st - pulp id of the repo"
  echo "  2nd - path to the directory with repo definition"
  exit
fi

repo_id=$1
dir=$2

#create the repository
pulp-admin auth login --username admin --password admin
pulp-admin repo create --id $repo_id

mkdir $dir/packages/

#batch build packages
./batch_create_dummy_packages.sh $dir/packagelist.txt $dir/packages
pulp-admin content upload -r $repo_id --nosig -v $dir/packages/*rpm

#create groups and categories
./create_repogroups.sh $repo_id $dir/grouplist.txt

#create errata
./batch_create_errata.sh $repo_id $dir/errata.txt $dir/packages/

#TODO: upload additional files


pulp-admin repo generate_metadata --id $repo_id

rm -r $dir/packages
