#testing products
test "product list by org and env" product list --org="$TEST_ORG" --environment="$TEST_ENV" --provider="$YUM_PROVIDER"
test "product list by org only" product list --org="$TEST_ORG"
test "product list by org and provider" product list --org="$TEST_ORG" --provider="$YUM_PROVIDER"
