#!/bin/bash

# testing registration from rhsm
RHSM_REGISTER="subscription-manager register --username=$USER --password=$PASSWORD --org=$FIRST_ORG --environment=$TEST_ENV_3 --name=$HOSTNAME --force"
if [ $PRINT_ALL -eq 1 ]; then
	echo $RHSM_REGISTER
	result=`$RHSM_REGISTER`
else
	printf "%-40s" "rhsm register"
	result=`$RHSM_REGISTER 2>&1`
fi


if [ $? -ne 0 ] || [ "`echo $result | egrep -i "'nt\b|\bnot\b|\bfail|\berror\b"`" ]; then
	if [ $PRINT_ALL -eq 1 ]; then
	printf "%s\n\n" "$result"
	else
	printf "[ ${txtred}FAILED${txtrst} ]\n"
	printf "\t%s\n" "$*"
	printf "\t%s\n" "$result"
    fi
    let failed_cnt+=1
else
    if [ $PRINT_ALL -eq 1 ]; then
        printf "%s\n\n" "$result"
	else
	printf "[ ${txtgrn}OK${txtrst} ]\n"
    fi
fi
let test_cnt+=1