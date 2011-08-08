#testing repositories
test "repo list by org and env" repo list --org="$FIRST_ORG" --environment="$TEST_ENV"
test "repo list by org only" repo list --org="$FIRST_ORG"
test "repo list by org and product" repo list --org="$FIRST_ORG" --product="$FEWUPS_PRODUCT"
REPO_NAME=`$CMD repo list --org="$FIRST_ORG" | grep $FEWUPS_REPO | awk '{print $2}'`
REPO_ID=`$CMD repo list --org="$FIRST_ORG" | grep $FEWUPS_REPO | awk '{print $1}'`
test "repo status for $REPO_ID" repo status --id="$REPO_ID"
test "repo synchronize for $REPO_ID" repo synchronize --id="$REPO_ID"
