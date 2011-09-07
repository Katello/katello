#!/bin/bash


# testing templates
TEMPLATE_NAME="template_$RAND"
TEMPLATE_NAME_2="template_2_$RAND"
test "template create" template create --name="$TEMPLATE_NAME" --description="template description" --org="$TEST_ORG"
test "template create with parent" template create --name="$TEMPLATE_NAME_2" --description="template 2 description" --parent="$TEMPLATE_NAME" --org="$TEST_ORG"
test "template list" template list --org="$TEST_ORG" --environment="Locker"
test "template update" template update --name="$TEMPLATE_NAME_2" --new_name="changed_$TEMPLATE_NAME_2" --description="changed description" --org="$TEST_ORG"
test "template update_content add product" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG"    --add_product    --product="$FEWUPS_PRODUCT"
test "template update_content add package" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG"    --add_package    --package="cheetah"
test "template update_content remove package" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG" --remove_package --package="cheetah"
test "template update_content add erratum" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG"    --add_erratum    --erratum="RHEA-2010:9984"
test "template update_content remove erratum" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG" --remove_erratum --erratum="RHEA-2010:9984"
test "template update_content remove product" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG" --remove_product --product="$FEWUPS_PRODUCT"
test "template update_content add parameter" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG"    --add_parameter    --parameter "attr" --value "X"
test "template update_content remove parameter" template update_content --name="$TEMPLATE_NAME" --org="$TEST_ORG" --remove_parameter --parameter "attr"
