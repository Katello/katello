#!/bin/bash
script_dir_link=$(dirname "$(readlink "$0")")
if [[ $script_dir_link == "." ]]; then
    script_dir=$(dirname "$0")
else
    script_dir=$script_dir_link
fi
export PYTHONPATH=$script_dir/../../cli/src


RAND=$(date | md5sum | cut -c1-6)
USER='admin'
PASSWORD='admin'
CMD_NOUSER="$script_dir/../../cli/bin/katello"
CMD="$CMD_NOUSER -u $USER -p $PASSWORD"

test_cnt=0
failed_cnt=0

# Text color variables
txtred=$(tput setaf 1)    # Red
txtgrn=$(tput setaf 2)    # Green
txtyel=$(tput setaf 3)    # Yellow
txtrst=$(tput sgr0)       # Text reset

all_tests=`ls $script_dir/cli_tests/ | grep -v _.* | sed -s 's/.sh//g'`
required_tests=""

PRINT_ALL=0
SHELL_MODE=0
TEST_ALL=0
for param in $*; do
    case "$param" in
        "-h"|"--help")
            printf "Simple script for testing Katello CLI\n\n"
            printf " -h, --help      prints this help\n"
            printf " -v,--verbose    verbose mode, prints full command output\n"
            printf " -s, --shell     runs tests in the shell mode\n"
            printf "\n"
            printf "Available tests:\n"
            printf " all\n"
            for t in $all_tests; do
            printf " %s\n" "$t"
            done
            printf "\n"
            printf "Usage:\n"
            printf " katello-cli-simple-test.sh <parameters> <list of tests>\n"
            printf "\n"
            exit
            ;;
        "-v"|"--verbose")
            PRINT_ALL=1        
            ;;
        "-s"|"--shell")
            SHELL_MODE=1
            ;;
        "all")
            TEST_ALL=1
            ;;
        *)
            required_tests="$required_tests $param"
            ;;
    esac
done

if [ $TEST_ALL -eq 1 ]; then
    required_tests=$all_tests
fi
echo $required_tests

function skip_test() {
    printf "%-40s" "$1"
    shift
    printf "[ ${txtyel}SKIPPED${txtrst} ]\t Notes: $1\n"
}

function test() {
    if [ $PRINT_ALL -eq 1 ]; then
        shift
        echo $DISP_CMD $*
    else
        printf "%-40s" "$1"
        shift        
    fi
  
  
    if [ $SHELL_MODE -eq 1 ]; then
        result=`echo -e "$*\nexit" | $CMD shell 2>&1`
        result=`echo "$result" | sed 's/katello>//g'`
    else
        result=`$CMD $* 2>&1`
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
}

function todo() {
  printf "%-40s" "$1"
  printf "[ TODO ]\n"
}

function summarize() {
  
    echo "---------------------------------------------"
    if [ $failed_cnt -eq 0 ]; then
        printf "%s tests, all passed\n" "$test_cnt"
    else
        printf "%s tests, %s failed\n" "$test_cnt" "$failed_cnt"
    fi

    exit $failed_cnt
}

function valid_id() {
    if [ -z "$1" ]; then
        return 0
    fi

    #id=`echo $1 | egrep '\+-+\+'`
    id=`echo $1 | egrep '\-{5,}'`
    if [ -z "$id" ]; then
        return 0
    else
        return 1
    fi
}


. $script_dir/cli_tests/_base_setup.sh
for t in $required_tests; do  
    . $script_dir/cli_tests/$t.sh
done

. $script_dir/cli_tests/_base_cleanup.sh

summarize

