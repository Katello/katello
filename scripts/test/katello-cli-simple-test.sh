#!/bin/bash
script_dir_link=$(dirname "$(readlink "$0")")
if [[ $script_dir_link == "." ]]; then
  script_dir=$(dirname "$0")
else
  script_dir=$script_dir_link
fi
export PYTHONPATH=$script_dir/../../cli/src
CMD=$script_dir/../../cli/bin/katello

RAND=$(date | md5sum | cut -c1-6)


test_cnt=0
failed_cnt=0

# Text color variables
txtred=$(tput setaf 1)    # Red
txtgrn=$(tput setaf 2)    # Green
txtrst=$(tput sgr0)       # Text reset

PRINT_ALL=0
if [ "$1" == "-v" ]; then
    PRINT_ALL=1
fi


function test() {
    if [ $PRINT_ALL -eq 1 ]; then
        shift
        echo katello $*
        $CMD $*
        return
    fi
  
    printf "%-40s" "$1"    
    shift
    result=`$CMD $* 2>&1`
    
    if [ $? -ne 0 ] || [ "`echo $result | egrep -i "'nt\b|\bnot\b|\bfail|\berror\b"`" ]; then
        printf "[ ${txtred}FAILED${txtrst} ]\n"
        printf "\t%s\n" "$*"
        printf "\t%s\n" "$result"
        let failed_cnt+=1
    else
        printf "[ ${txtgrn}OK${txtrst} ]\n"
    fi
    let test_cnt+=1
}

function todo() {
  printf "%-40s" "$1"
  printf "[ TODO ]\n"
}

function summarize() {
    if [ $PRINT_ALL -eq 1 ]; then
        return
    fi
  
    echo "---------------------------------------------"
    if [ $failed_cnt -eq 0 ]; then
        printf "%s tests, all passed\n" "$test_cnt"
    else
        printf "%s tests, %s failed\n" "$test_cnt" "$failed_cnt"
    fi
}

function valid_id() {
    if [ -z "$1" ]; then
        return 0
    fi
  
    id=`echo $1 | egrep '\+-+\+'`
    if [ -z "$id" ]; then
        return 0
    else
        return 1
    fi
}

#testing organization
FIRST_ORG=ACME_Corporation
TEST_ORG="org_$RAND"
test "org create" org create --name=$TEST_ORG --description="org description"
test "org update" org update --name=$TEST_ORG --description="org description 2"
test "org list" org list
test "org info" org info --name=$TEST_ORG

#testing environments
TEST_ENV="env_$RAND"
TEST_ENV_2="env_2_$RAND"
TEST_ENV_3="env_3_$RAND"
test "environment create" environment create --org="$FIRST_ORG" --name="$TEST_ENV"
test "environment create with prior" environment create --org="$FIRST_ORG" --name="$TEST_ENV_2" --prior="$TEST_ENV"
test "environment update" environment update --org="$FIRST_ORG" --name="$TEST_ENV_2" --new_name="$TEST_ENV_3"
test "environment list" environment list --org="$FIRST_ORG"
test "environment info" environment info --org="$FIRST_ORG" --name="$TEST_ENV"

#testing provider
YUM_PROVIDER="yum_provider_$RAND"
FEWUPS_REPO="http://lzap.fedorapeople.org/fakerepos/fewupdates/"
FEWUPS_REPO_2="http://lzap.fedorapeople.org/fakerepos/fewupdates/2/"
test "provider create" provider create --name="$YUM_PROVIDER" --org="$FIRST_ORG" --type=yum --url="$FEWUPS_REPO" --description="prov description"
test "provider update" provider update --name="$YUM_PROVIDER" --org="$FIRST_ORG" --url="$FEWUPS_REPO_2" --description="prov description 2"
test "provider list" provider list --org="$FIRST_ORG"
test "provider info" provider info --name="$YUM_PROVIDER" --org="$FIRST_ORG"

#testing products
FEWUPS_PRODUCT="fewups_product_$RAND"
test "product create" product create --provider="$YUM_PROVIDER" --org="$FIRST_ORG" --name="$FEWUPS_PRODUCT" --url="$FEWUPS_REPO"
test "product list by org and env" product list --org="$FIRST_ORG" --environment="$TEST_ENV" --provider="$YUM_PROVIDER"
test "product list by org only" product list --org="$FIRST_ORG"
test "product list by org and provider" product list --org="$FIRST_ORG" --provider="$YUM_PROVIDER"

#testing repositories
REPO="repo_$RAND"
test "repo create" repo create --product="$FEWUPS_PRODUCT" --org="$FIRST_ORG" --name="$REPO" --url="$FEWUPS_REPO"
test "repo list by org and env" repo list --org="$FIRST_ORG" --environment="$TEST_ENV"
test "repo list by org only" repo list --org="$FIRST_ORG"
test "repo list by org and product" repo list --org="$FIRST_ORG" --product="$FEWUPS_PRODUCT"
REPO_ID=`$CMD repo list --org="$FIRST_ORG" | grep $REPO | awk '{print $1}'`
test "repo status" repo status --id="$REPO_ID"

#testing provider sync
test "provider sync" provider sync --name="$YUM_PROVIDER" --org="$FIRST_ORG"
sleep 1 #give the provider some time to get synced

#testing systems
SYSTEM_NAME="mysystem_$RAND"
CONSUMER_FIRST="$(echo $FIRST_ORG|perl -e 'print lc <>;')_user"
test "system register" -u $CONSUMER_FIRST -p $CONSUMER_FIRST system register --name="$SYSTEM_NAME"
test "system list" system list --org="$FIRST_ORG"

#testing distributions
test "distribution list by repo id" distribution list --repo_id="$REPO_ID"
test "distribution list" distribution list --repo="$REPO" --org="$FIRST_ORG" --product="$FEWUPS_PRODUCT"

#testing packages
test "package list by repo id" package list --repo_id="$REPO_ID"
test "package list" package list --repo="$REPO" --org="$FIRST_ORG" --product="$FEWUPS_PRODUCT"
PACK_ID=`$CMD package list --repo_id="$REPO_ID" | tail -n 1 | awk '{print $1}'`
if valid_id $PACK_ID; then
    test "package info" package info --id="$PACK_ID"
fi

#testing erratas
test "errata list by repo id" errata list --repo_id="$REPO_ID"
test "errata list" errata list --repo="$REPO" --org="$FIRST_ORG" --product="$FEWUPS_PRODUCT"
ERRATA_ID=`$CMD errata list --repo_id="$REPO_ID" | tail -n 1 | awk '{print $1}'`
if valid_id $ERRATA_ID; then
    test "errata info" errata info --id="$ERRATA_ID"
fi

#testing templates
test "template list" template list


#testing ping
test "ping" ping

#clear
#test "repo delete" repo delete       # <-- not implemented yet
#test "product delete" product delete # <-- not implemented yet
test "provider delete" provider delete --name="$YUM_PROVIDER" --org="$FIRST_ORG"
test "environment delete" environment delete --name="$TEST_ENV" --org="$FIRST_ORG"
test "environment delete" environment delete --name="$TEST_ENV_3" --org="$FIRST_ORG"
test "org delete" org delete --name="$TEST_ORG"




summarize





