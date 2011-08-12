#testing repositories
test "repo list by org and env" repo list --org="$FIRST_ORG" --environment="$TEST_ENV"
test "repo list by org only" repo list --org="$FIRST_ORG"
test "repo list by org and product" repo list --org="$FIRST_ORG" --product="$FEWUPS_PRODUCT"
test "repo status" repo status --id="$REPO_ID"
test "repo synchronize" repo synchronize --id="$REPO_ID"
