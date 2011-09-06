REPO_ID=`$CMD repo list --org="$TEST_ORG" -g | grep $FEWUPS_REPO | awk '{print $1}'`
PACKAGE_GROUP_ID=test
PACKAGE_GROUP_CATEGORY_ID=test

# create sample package group and category
curl -k -u admin:admin  -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d \
"{\"groupid\":\"$PACKAGE_GROUP_ID\",\"groupname\":\"test\",\"description\":\"test description\"}" -s \
https://localhost/pulp/api/repositories/$REPO_ID/create_packagegroup/ > /dev/null

curl  -k -u admin:admin -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d \
"{\"categoryid\":\"$PACKAGE_GROUP_CATEGORY_ID\",\"categoryname\":\"test\",\"description\":\"test description\"}" -s \
https://localhost/pulp/api/repositories/$REPO_ID/create_packagegroupcategory/ > /dev/null

curl -k -u admin:admin -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d \
"{\"categoryid\":\"$PACKAGE_GROUP_CATEGORY_ID\",\"groupid\":\"$PACKAGE_GROUP_ID\"}" -s  \
https://localhost/pulp/api/repositories/$REPO_ID/add_packagegroup_to_category/ > /dev/null

test "list package groups" package_group list --repoid $REPO_ID
test "show package group" package_group info --repoid $REPO_ID --id $PACKAGE_GROUP_ID

test "list package group categories" package_group category_list --repoid $REPO_ID
test "shod pacakge group category" package_group category_info --repoid $REPO_ID --id $PACKAGE_GROUP_CATEGORY_ID
