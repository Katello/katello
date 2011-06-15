#!/bin/sh

MY_DIR=`dirname $0`
source $MY_DIR/utils.sh


#test java version
if [[ $JAVA_HOME == *java-1.6.0-openjdk* ]]
then
	msgOK 'java is java-1.6.0-openjdk-1.6.0.0'
	exit 0
else
	msgFail 'java is not java-1.6.0-openjdk-1.6.0.0' 'install openjdk 1.6.0 and configure it as system java'
	exit 1
fi

