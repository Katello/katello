#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Script for generating dummy packages from a definition file"
  echo "takes 2 params:"
  echo "  1st - path to the definition file"
  echo "  2nd - path to the output directory"
  exit
fi


package_list=$1
out_dir=$2

cat $package_list | while read line; do

    echo "./create_dummy_package.sh $line $out_dir"
    ./create_dummy_package.sh $line $out_dir
done
