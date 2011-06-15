#!/bin/sh

MY_DIR=`dirname $0`
source $MY_DIR/utils.sh


checkProcessRunning 'qpidd'
exit $?
