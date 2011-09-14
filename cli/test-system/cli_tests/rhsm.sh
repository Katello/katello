#!/bin/bash

RHSM_ORG="org_rhsm_$RAND"
RHSM_ENV="env_rhsm_$RAND"
RHSM_AK1="ak1_$RAND"
RHSM_AK2="ak2_$RAND"

sm_present() {
  which subscription-manager &> /dev/null
  return $?
}

# testing registration from rhsm
if sm_present; then
  test "org create for rhsm" org create --name=$RHSM_ORG --description="org for rhsm"
  test "environment create for rhsm" environment create --org="$RHSM_ORG" --name="$RHSM_ENV" --prior="Locker"
  test "activation key 1 create" activation_key create --name="$RHSM_AK1" --description="rhsm key" --environment="$RHSM_ENV" --org="$RHSM_ORG"
  test "activation key 2 create" activation_key create --name="$RHSM_AK2" --description="rhsm key" --environment="$RHSM_ENV" --org="$RHSM_ORG"

  test_own_cmd "rhsm registration with org" sudo subscription-manager register --username=$USER --password=$PASSWORD \
    --org=$RHSM_ORG --name=$HOSTNAME --force
  test_own_cmd "rhsm registration with org/env" sudo subscription-manager register --username=$USER --password=$PASSWORD \
    --org=$RHSM_ORG --environment=$RHSM_ENV --name=$HOSTNAME --force
  test_own_cmd "rhsm registration with one ak" sudo subscription-manager register \
    --org=$RHSM_ORG --activationkey="$RHSM_AK1" --force
  test_own_cmd "rhsm registration with two aks" sudo subscription-manager register \
    --org=$RHSM_ORG --activationkey="$RHSM_AK1,$RHSM_AK2" --force
  test_own_cmd "rhsm list" sudo subscription-manager list
  test_own_cmd "rhsm list available" sudo subscription-manager list --available
  test_own_cmd "rhsm facts update" sudo subscription-manager facts --update
  test_own_cmd "rhsm unregister" sudo subscription-manager unregister

  test "delete activation key" activation_key delete --org="$RHSM_ORG" --name="$RHSM_AK1"
  test "environment delete for rhsm" environment delete --name="$RHSM_ENV" --org="$RHSM_ORG"
  test "org delete for rhsm" org delete --name="$RHSM_ORG"
else
  skip_test "rhsm registration" "subscription-manager command not found"
fi
