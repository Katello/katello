#testing repositories
test "repo list by org and env" repo list --org="$TEST_ORG" --environment="$TEST_ENV"
test "repo list by org only" repo list --org="$TEST_ORG"
test "repo list by org and product" repo list --org="$TEST_ORG" --product="$FEWUPS_PRODUCT"
REPO_NAME=`$CMD repo list --org="$TEST_ORG" -g | grep $FEWUPS_REPO | awk '{print $2}'`
REPO_ID=`$CMD repo list --org="$TEST_ORG" -g | grep $FEWUPS_REPO | awk '{print $1}'`
test "repo status" repo status --id="$REPO_ID"
test "repo synchronize" repo synchronize --id="$REPO_ID"
