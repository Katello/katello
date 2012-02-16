#!/bin/bash

header "RHSM"

RHSM_ORG="org_rhsm_$RAND"
RHSM_ENV="env_rhsm_$RAND"
RHSM_AK1="ak1_$RAND"
RHSM_AK2="ak2_$RAND"
RHSM_YPROV="yum_$RAND"
CS1_NAME="changeset_$RAND"
RHSM_REPO="http://lzap.fedorapeople.org/fakerepos/zoo/"
RHSM_YPROD="yum_product_$RAND"
HOST="$(hostname)_$RAND"

sm_present() {
  which subscription-manager &> /dev/null
  return $?
}

# testing registration from rhsm
if sm_present; then
  test_success "org create for rhsm" org create --name=$RHSM_ORG --description="org for rhsm"
  test_success "environment create for rhsm" environment create --org="$RHSM_ORG" --name="$RHSM_ENV" --prior="Library"
  test_success "activation key 1 create" activation_key create --name="$RHSM_AK1" --environment="$RHSM_ENV" --org="$RHSM_ORG"
  test_success "activation key 2 create" activation_key create --name="$RHSM_AK2" --environment="$RHSM_ENV" --org="$RHSM_ORG"
  test_success "provider create" provider create --name="$RHSM_YPROV" --org="$RHSM_ORG" --url="$RHSM_REPO"
  test_success "product create" product create --provider="$RHSM_YPROV" --org="$RHSM_ORG" --name="$RHSM_YPROD" --url="$RHSM_REPO" --assumeyes
  test_success "changeset create" changeset create --org="$RHSM_ORG" --environment="$RHSM_ENV" --name="$CS1_NAME"
  test_success "changeset add product" changeset update  --org="$RHSM_ORG" --environment="$RHSM_ENV" --name="$CS1_NAME" --add_product="$RHSM_YPROD"
  check_delayed_jobs_running
  test_success "changeset promote" changeset promote --org="$RHSM_ORG" --environment="$RHSM_ENV" --name="$CS1_NAME"

  test_own_cmd_success "rhsm show organizations" sudo subscription-manager orgs --username=$USER --password=$PASSWORD
  test_own_cmd_success "rhsm show environments" sudo subscription-manager environments --username=$USER --password=$PASSWORD --org=$RHSM_ORG
  test_own_cmd_success "rhsm registration with org" sudo subscription-manager register --username=$USER --password=$PASSWORD \
    --org=$RHSM_ORG --name=$HOST --force
  test_own_cmd_success "rhsm show identity" sudo subscription-manager identity
  test_own_cmd_success "rhsm registration with org/env" sudo subscription-manager register --username=$USER --password=$PASSWORD \
    --org=$RHSM_ORG --environment=$RHSM_ENV --name=$HOST --force
  test_own_cmd_success "rhsm regenerate identity" sudo subscription-manager identity --regenerate
  test_own_cmd_success "rhsm registration with one ak" sudo subscription-manager register \
    --org=$RHSM_ORG --activationkey="$RHSM_AK1" --name=$HOST --force
  test_own_cmd_success "rhsm force regenerate identity" sudo subscription-manager identity --regenerate --force --username=$USER --password=$PASSWORD
  test_own_cmd_success "rhsm registration with two aks" sudo subscription-manager register \
    --org=$RHSM_ORG --activationkey="$RHSM_AK1,$RHSM_AK2" --name=$HOST --force
  # we expect we have installed a product and can't auto subscribe
  test_own_cmd_exit_code 1 "rhsm auto subscribe" sudo subscription-manager subscribe --auto
  test_own_cmd_success "rhsm list all" sudo subscription-manager list --available --all
  POOLID=$(sudo subscription-manager list --available --all | grep PoolId | head -n1 | awk '{print $2}') # grab first pool
  test_own_cmd_success "rhsm subscribe to pool" sudo subscription-manager subscribe --pool $POOLID
  test_own_cmd_success "rhsm list" sudo subscription-manager list
  test_own_cmd_success "rhsm list available" sudo subscription-manager list --available
  test_own_cmd_success "rhsm list consumed" sudo subscription-manager list --consumed
  test_own_cmd_success "rhsm list ondate" sudo subscription-manager list --ondate=2011-09-15 --available
  test_own_cmd_success "rhsm list repos" sudo subscription-manager repos --list
  test_own_cmd_success "rhsm refresh" sudo subscription-manager refresh
  SERIAL=$(sudo subscription-manager list --consumed | grep SerialNumber | head -n1 | awk '{print $2}') # grab first serial
  test_own_cmd_success "rhsm unsubscribe to serial" sudo subscription-manager unsubscribe --serial=$SERIAL
  test_own_cmd_success "rhsm subscribe to pool" sudo subscription-manager subscribe --pool $POOLID # again
  test_own_cmd_success "rhsm unsubscribe all" sudo subscription-manager unsubscribe --all
  test_own_cmd_success "rhsm facts update" sudo subscription-manager facts --update
  test_own_cmd_success "rhsm unregister" sudo subscription-manager unregister

  # should cascade and delete everything
  test_success "org delete for rhsm" org delete --name="$RHSM_ORG"
else
  skip_test_success "rhsm registration" "subscription-manager command not found"
fi
