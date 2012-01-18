#!/bin/bash

header "Sync Plan"

PLAN_1_NAME='plan_1'
PLAN_1_NEW_NAME='plan_1_updated'
PLAN_2_NAME='plan_2'

test_success "sync_plan create recurrent" sync_plan create --org="$TEST_ORG" --name="$PLAN_1_NAME"\
 --description="plan 1 desc." --date="2012-01-01" --time="09:00:00" --interval="weekly"
test_success "sync_plan create simple"    sync_plan create --org="$TEST_ORG" --name="$PLAN_2_NAME"\
 --description="plan 2 desc." --date="2012-01-01" --time="09:00:00"

test_success "sync_plan list" sync_plan list --org="$TEST_ORG"
test_success "sync_plan update" sync_plan update --org="$TEST_ORG" --name="$PLAN_1_NAME" \
 --new_name="$PLAN_1_NEW_NAME" --description="new plan 1 desc." --date="2012-02-02" --time="10:10:10" --interval="daily"

test_success "product set_plan 1" product set_plan --org="$TEST_ORG" --name="$FEWUPS_PRODUCT" --plan="$PLAN_1_NEW_NAME"
test_success "product set_plan 2" product set_plan --org="$TEST_ORG" --name="$FEWUPS_PRODUCT" --plan="$PLAN_2_NAME"
test_success "product remove_plan" product remove_plan --org="$TEST_ORG" --name="$FEWUPS_PRODUCT"

test_success "sync_plan delete" sync_plan delete --org="$TEST_ORG" --name="$PLAN_1_NEW_NAME"
test_success "sync_plan delete" sync_plan delete --org="$TEST_ORG" --name="$PLAN_2_NAME"
