#!/bin/bash

function usage() {
  cat <<EOF
Script for generating fake cds from definition files

Arguments:
  -d  - path to the directory with cds definition
  -o  - path to the output directory

The see cds for samples definitino. The repo name references the repo
definitions.
EOF
}

while getopts "d:o:" opt; do
    case "$opt" in
        d)  dir=$OPTARG ;;
        o)  out_dir=$OPTARG ;;
        ?)  usage
            exit 1;;
    esac
done

if [ -z "$dir" ] || [ -z "$out_dir" ]; then
   usage
   exit 1
fi

mkdir -p $out_dir/source

if ! [ -d $out_dir ]; then
    echo "$out_dir is not a directory"
    exit 2
fi

function update_listing_file {
    dir=$1
    ls -1 $dir | grep -v listing > $dir/listing
}

function create_subrepo() {
    product=$1
    version=$2
    arch=$3
    repo=$4

    target_dir=$out_dir/content/$product/$version/$arch
    repo_dir=$out_dir/source/$repo

    if ! [ -e $repo_dir ]; then
        ./create_repo.sh -d $repo -o $repo_dir
    fi

    mkdir -p $target_dir
    ln -s ../../../../source/$repo/RPMS $target_dir/rpms
    ln -s ../../../../source/$repo/SRPMS $target_dir/srpms

    update_listing_file $out_dir/content/$product
    update_listing_file $out_dir/content/$product/$version
}

cat $dir/meta.txt | while read line; do
    create_subrepo $line
done
