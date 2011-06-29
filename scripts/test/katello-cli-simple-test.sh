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
PASSWORD='password123'
CMD="$script_dir/../../cli/bin/katello -u $USER -p $PASSWORD"

test_cnt=0
failed_cnt=0

# Text color variables
txtred=$(tput setaf 1)    # Red
txtgrn=$(tput setaf 2)    # Green
txtrst=$(tput sgr0)       # Text reset

PRINT_ALL=0
SHELL_MODE=0
for param in $*; do
    case "$param" in
        "-h"|"--help")
            printf "Simple script for testing Katello CLI\n\n"
            printf " -h, --help      prints this help\n"
            printf " -v,--verbose    verbose mode, only running the commands in cli\n"
            printf " -s, --shell     runs tests in the shell mode\n"
            printf "\n"
            exit
            ;;
        "-v"|"--verbose")
            PRINT_ALL=1        
            ;;
        "-s"|"--shell")
            SHELL_MODE=1
            ;;
    esac
done



function test() {
    if [ $PRINT_ALL -eq 1 ]; then
        shift
        echo katello $*
        $CMD $*
        return
    fi
  
    printf "%-40s" "$1"
    shift
    
    if [ $SHELL_MODE -eq 1 ]; then
        result=`echo -e "$*\nexit" | $CMD shell 2>&1`
        result=`echo "$result" | sed 's/katello>//g'`
    else
        result=`$CMD $* 2>&1`
    fi


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

test "org delete" org delete --name="XXX"
exit

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
test "environment create" environment create --org="$FIRST_ORG" --name="$TEST_ENV" --prior="locker"
test "environment create with prior" environment create --org="$FIRST_ORG" --name="$TEST_ENV_2" --prior="$TEST_ENV"
test "environment update" environment update --org="$FIRST_ORG" --name="$TEST_ENV_2" --new_name="$TEST_ENV_3"
test "environment list" environment list --org="$FIRST_ORG"
test "environment info" environment info --org="$FIRST_ORG" --name="$TEST_ENV"

#testing provider
YUM_PROVIDER="yum_provider_$RAND"
FEWUPS_REPO="http://lzap.fedorapeople.org/fakerepos/"
FEWUPS_REPO_2="http://lzap.fedorapeople.org/fakerepos/2/"
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
test "repo create" repo create --product="$FEWUPS_PRODUCT" --org="$FIRST_ORG" --name="$REPO" --url="$FEWUPS_REPO" --assumeyes
test "repo list by org and env" repo list --org="$FIRST_ORG" --environment="$TEST_ENV"
test "repo list by org only" repo list --org="$FIRST_ORG"
test "repo list by org and product" repo list --org="$FIRST_ORG" --product="$FEWUPS_PRODUCT"
REPO_NAME=`$CMD repo list --org="$FIRST_ORG" | grep $REPO | awk '{print $2}'`
REPO_ID=`$CMD repo list --org="$FIRST_ORG" | grep $REPO | awk '{print $1}'`
test "repo status" repo status --id="$REPO_ID" -v

#testing provider sync
test "provider sync" provider sync --name="$YUM_PROVIDER" --org="$FIRST_ORG"
sleep 1 #give the provider some time to get synced

#testing systems
SYSTEM_NAME="_system_$RAND"
CONSUMER_FIRST="$(echo $FIRST_ORG|perl -e 'print lc <>;')_user"
test "system register as admin" system register --name="admin$SYSTEM_NAME" --org="$FIRST_ORG"
test "system register as user" -u $CONSUMER_FIRST -p $CONSUMER_FIRST system register --name="user$SYSTEM_NAME" --org="$FIRST_ORG"
test "system list" system list --org="$FIRST_ORG"

#testing distributions
test "distribution list by repo id" distribution list --repo_id="$REPO_ID"
test "distribution list" distribution list --repo="$REPO_NAME" --org="$FIRST_ORG" --product="$FEWUPS_PRODUCT"

#testing packages
test "package list by repo id" package list --repo_id="$REPO_ID"
test "package list" package list --repo="$REPO_NAME" --org="$FIRST_ORG" --product="$FEWUPS_PRODUCT"
PACK_ID=`$CMD package list --repo_id="$REPO_ID" | tail -n 1 | awk '{print $1}'`
if valid_id $PACK_ID; then
    test "package info" package info --id="$PACK_ID"
fi

#testing erratas
test "errata list by repo id" errata list --repo_id="$REPO_ID"
test "errata list" errata list --repo="$REPO_NAME" --org="$FIRST_ORG" --product="$FEWUPS_PRODUCT"
ERRATA_ID=`$CMD errata list --repo_id="$REPO_ID" | tail -n 1 | awk '{print $1}'`
if valid_id $ERRATA_ID; then
    test "errata info" errata info --id="$ERRATA_ID"
fi


#testing templates
TEMPLATE_NAME="template_$RAND"
TEMPLATE_NAME_2="template_2_$RAND"
test "template create" template create --name="$TEMPLATE_NAME" --description="template description" --org="$FIRST_ORG"
test "template create with parent" template create --name="$TEMPLATE_NAME_2" --description="template 2 description" --parent="$TEMPLATE_NAME" --org="$FIRST_ORG"
test "template list" template list
test "template update" template update --name="$TEMPLATE_NAME_2" --new_name="changed_$TEMPLATE_NAME_2" --description="changed description" --org="$FIRST_ORG"
test "template update_content add product" template update_content --name="$TEMPLATE_NAME" --org="$FIRST_ORG"    --add_product    --product="$FEWUPS_PRODUCT"
test "template update_content add package" template update_content --name="$TEMPLATE_NAME" --org="$FIRST_ORG"    --add_package    --package="warnerbros"
test "template update_content remove package" template update_content --name="$TEMPLATE_NAME" --org="$FIRST_ORG" --remove_package --package="warnerbros"
test "template update_content add erratum" template update_content --name="$TEMPLATE_NAME" --org="$FIRST_ORG"    --add_erratum    --erratum="RHEA-2010:9999"
test "template update_content remove erratum" template update_content --name="$TEMPLATE_NAME" --org="$FIRST_ORG" --remove_erratum --erratum="RHEA-2010:9999"
test "template update_content remove product" template update_content --name="$TEMPLATE_NAME" --org="$FIRST_ORG" --remove_product --product="$FEWUPS_PRODUCT"
test "template update_content add parameter" template update_content --name="$TEMPLATE_NAME" --org="$FIRST_ORG"    --add_parameter    --parameter "attr" --value "X"
test "template update_content remove parameter" template update_content --name="$TEMPLATE_NAME" --org="$FIRST_ORG" --remove_parameter --parameter "attr"



#testing ping
test "ping" ping

#clear
#test "repo delete" repo delete       # <-- not implemented yet
#test "product delete" product delete # <-- not implemented yet
test "template delete" template delete --name="changed_$TEMPLATE_NAME_2" --org="$FIRST_ORG"
test "template delete" template delete --name="$TEMPLATE_NAME" --org="$FIRST_ORG"
test "provider delete" provider delete --name="$YUM_PROVIDER" --org="$FIRST_ORG"
test "environment delete" environment delete --name="$TEST_ENV" --org="$FIRST_ORG"
test "environment delete" environment delete --name="$TEST_ENV_3" --org="$FIRST_ORG"
test "org delete" org delete --name="$TEST_ORG"




summarize





