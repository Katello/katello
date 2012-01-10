#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Script for adding package groups to a pulp repository"
  echo "takes 2 params:"
  echo "  1st - pulp id of the repo"
  echo "  2nd - path to a file with group definition"
  exit
fi


repoid=$1
group_list=$2

cat $group_list | while read line; do

    group=${line% *}
    group_type=${group:0:1}
    contents=${line#* }

    #create the group or category
    if [ "$group_type" == "@" ]; then
        #create group
        group=${group#@}
        pulp-admin packagegroup create -r $repoid --id $group -n $group
    else
        #create category
        group=${group#\#}
        pulp-admin packagegroup create_category -r $repoid --categoryid $group -n $group
    fi

    for content in `echo $contents | sed "s/,/ /g"`; do
        if [ ${content:0:1} == "@" ]; then
            #add group to another group
            pulp-admin packagegroup add_group -r $repoid --categoryid $group --id ${content#@}
        else
            #add package to group
            pulp-admin packagegroup add_package -r $repoid --id $group -t mandatory -n $content
        fi
    done
done


