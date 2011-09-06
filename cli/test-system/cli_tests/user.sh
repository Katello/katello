#testing user
test "user update" user update --username=$TEST_USER --password=password
test "user list" user list
test "user info" user info --username=$TEST_USER
