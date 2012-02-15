#!/bin/bash

# echo $1
export PNAME=`echo $1 | sed s/.gem//g | awk -F- '{ print $1 }'`
echo $PNAME


mkdir $PNAME
cp $1 $PNAME
cd $PNAME
gem2rpm $1 -o $PNAME.spec

