test "org update" org update --name=$TEST_ORG --description="org description 2"
test "org list" org list
test "org info" org info --name=$TEST_ORG
