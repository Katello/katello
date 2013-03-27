#!/bin/bash

header "Content View"

DEF1="def1_$RAND"
DEF1_VIEW1="${DEF1}_view1_$RAND"
DEF1_VIEW2="${DEF1}_view2_$RAND"
DEF2="def2_$RAND"
DEF2_VIEW1="${DEF2}_view1_$RAND"
DEF2_VIEW2="${DEF2}_view2_$RAND"
DEF3="def3_$RAND"
DEF3_VIEW1="${DEF3}_view1_$RAND"


test_success "content definition create ($DEF1)" content definition create --org="$TEST_ORG" --name="$DEF1"
test_success "content definition create ($DEF2)" content definition create --org="$TEST_ORG" --name="$DEF2"
test_success "content definition create ($DEF3)" content definition create --org="$TEST_ORG" --name="$DEF3"

test_success "repo synchronize ($FEWUPS_REPO)" repo synchronize --org="$TEST_ORG" --name="$FEWUPS_REPO" --product_label="$FEWUPS_PRODUCT"

test_success "content definition add_product ($FEWUPS_PRODUCT to $DEF1)" content definition add_product --org="$TEST_ORG" --name="$DEF1" --product="$FEWUPS_PRODUCT"
test_success "content definition add_repo ($FEWUPS_REPO to $DEF2)" content definition add_repo --org="$TEST_ORG" --name="$DEF2" --repo="$FEWUPS_REPO" --product="$FEWUPS_PRODUCT"

test_success "content definition publish ($DEF1 to $DEF1_VIEW1)" content definition publish --org="$TEST_ORG" --view_name="$DEF1_VIEW1" --label="$DEF1"
test_success "content definition publish ($DEF1 to $DEF1_VIEW2)" content definition publish --org="$TEST_ORG" --view_name="$DEF1_VIEW2" --name="$DEF1"
test_success "content definition publish ($DEF1 to $DEF2_VIEW1)" content definition publish --org="$TEST_ORG" --view_name="$DEF2_VIEW1" --label="$DEF2"
test_success "content definition publish ($DEF2 to $DEF2_VIEW2)" content definition publish --org="$TEST_ORG" --view_name="$DEF2_VIEW2" --name="$DEF2"

test_success "content definition add_content_view ($DEF2_VIEW2 to $DEF3)" content definition add_view --org="$TEST_ORG" --label="$DEF3" --view_label="$DEF2_VIEW2"
test_success "content definition publish ($DEF3 to $DEF3_VIEW1)" content definition publish --org="$TEST_ORG" --view_name="$DEF3_VIEW1" --name="$DEF3"

test_success "content view promote ($DEF1_VIEW1 to $TEST_ENV)" content view promote --org="$TEST_ORG" --name="$DEF1_VIEW1" --env="$TEST_ENV"
test_success "content view promote ($DEF1_VIEW2 to $TEST_ENV)" content view promote --org="$TEST_ORG" --name="$DEF1_VIEW2" --env="$TEST_ENV"
test_success "content view promote ($DEF2_VIEW1 to $TEST_ENV)" content view promote --org="$TEST_ORG" --name="$DEF2_VIEW1" --env="$TEST_ENV"
test_success "content view promote ($DEF2_VIEW1 to $TEST_ENV_2)" content view promote --org="$TEST_ORG" --name="$DEF2_VIEW1" --env="$TEST_ENV_2"
test_success "content view promote ($DEF2_VIEW2 to $TEST_ENV)" content view promote --org="$TEST_ORG" --name="$DEF2_VIEW2" --env="$TEST_ENV"
test_success "content view promote ($DEF1_VIEW2 to $TEST_ENV_2)" content view promote --org="$TEST_ORG" --name="$DEF1_VIEW2" --env="$TEST_ENV_2"

test_success "content view refresh ($DEF1_VIEW2)" content view refresh --org="$TEST_ORG" --label="$DEF1_VIEW2"
test_success "content view refresh ($DEF1_VIEW2)" content view refresh --org="$TEST_ORG" --label="$DEF1_VIEW2"
test_success "content view refresh ($DEF2_VIEW2)" content view refresh --org="$TEST_ORG" --label="$DEF2_VIEW2"

test_success "content view promote ($DEF1_VIEW2)" content view promote --org="$TEST_ORG" --name="$DEF1_VIEW2" --env="$TEST_ENV"
