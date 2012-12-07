#!/bin/bash

header "RHSM"


RHSM_ORG="org_rhsm_$RAND"
RHSM_ORG_LABEL="org_rhsm_label_$RAND"
RHSM_ENV="env_rhsm_$RAND"
RHSM_AK1=$(nospace "ak1_$RAND")
RHSM_AK2=$(nospace "ak2_$RAND")
RHSM_YPROV="yum_$RAND"
CS1_NAME="changeset_$RAND"
RHSM_REPO="http://lzap.fedorapeople.org/fakerepos/zoo/"
RHSM_YPROD="yum_product_$RAND"
RHSM_ZPROD="yum_product2_$RAND"
HOST="$(hostname)_$PLAIN_RAND"

sm_present() {
  which subscription-manager &> /dev/null
  return $?
}

grab_pool_with_rhsm() {
  $SUDO subscription-manager list --available --all | grep '^Pool Id' | head -n1 | awk '{print $3}'
}

grab_pool_with_katello() {
    $CMD org subscriptions --name "$RHSM_ORG" -g -d ";" | grep "$RHSM_YPROD" | awk -F ' *; *' '{print $3}'
}

# testing registration from rhsm
if sm_present; then
  if grep 'hostname = subscription.rhn.redhat.com' /etc/rhsm/rhsm.conf; then
    skip_test_success "rhsm registration" "Could not test against hosted"
  else
    test_success "org create for rhsm" org create --name="$RHSM_ORG" --label="$RHSM_ORG_LABEL" --description="org for rhsm"
    test_success "environment create for rhsm" environment create --org="$RHSM_ORG" --name="$RHSM_ENV" --prior="Library"
    test_success "activation key 1 create" activation_key create --name="$RHSM_AK1" --environment="$RHSM_ENV" --org="$RHSM_ORG"
    test_success "activation key 2 create" activation_key create --name="$RHSM_AK2" --environment="$RHSM_ENV" --org="$RHSM_ORG"
    test_success "provider create" provider create --name="$RHSM_YPROV" --org="$RHSM_ORG" --url="$RHSM_REPO"
    test_success "product create" product create --provider="$RHSM_YPROV" --org="$RHSM_ORG" --name="$RHSM_YPROD" --url="$RHSM_REPO" --assumeyes
    test_success "product create" product create --provider="$RHSM_YPROV" --org="$RHSM_ORG" --name="$RHSM_ZPROD" --url="$RHSM_REPO" --assumeyes
    POOLID=$(grab_pool_with_katello)
    test_success "add product to ak 1" activation_key update --add_subscription="$POOLID" --name="$RHSM_AK1" --environment="$RHSM_ENV" --org="$RHSM_ORG"
    test_success "changeset create" changeset create --org="$RHSM_ORG" --environment="$RHSM_ENV" --name="$CS1_NAME"
    test_success "changeset add product" changeset update  --org="$RHSM_ORG" --environment="$RHSM_ENV" --name="$CS1_NAME" --add_product="$RHSM_YPROD"
    check_delayed_jobs_running
    test_success "changeset promote" changeset promote --org="$RHSM_ORG" --environment="$RHSM_ENV" --name="$CS1_NAME"
    
    test_own_cmd_success "rhsm show organizations" $SUDO subscription-manager orgs --username="$USER" --password="$PASSWORD"
    test_own_cmd_success "rhsm show environments" $SUDO subscription-manager environments --username="$USER" --password="$PASSWORD" --org="$RHSM_ORG"
    test_own_cmd_success "rhsm registration with org label" \
      $SUDO subscription-manager register --username="$USER" --password="$PASSWORD" --org="$RHSM_ORG_LABEL" --name="$HOST" --force
    test_own_cmd_success "rhsm unregister" $SUDO subscription-manager unregister
    test_own_cmd_success "rhsm registration with org name" \
      $SUDO subscription-manager register --username="$USER" --password="$PASSWORD" --org="$RHSM_ORG" --name="$HOST" --force
    test_own_cmd_success "rhsm show identity" $SUDO subscription-manager identity
    test_own_cmd_success "rhsm registration with org/env" $SUDO subscription-manager register --username="$USER" --password="$PASSWORD" \
      --org="$RHSM_ORG" --environment="$RHSM_ENV" --name="$HOST" --force
    test_own_cmd_success "rhsm regenerate identity" $SUDO subscription-manager identity --regenerate
    test_own_cmd_success "rhsm registration with one ak" $SUDO subscription-manager register \
      --org="$RHSM_ORG" --activationkey="$RHSM_AK1" --name="$HOST" --force
    test_own_cmd_success "rhsm force regenerate identity" $SUDO subscription-manager identity --regenerate --force --username="$USER" --password="$PASSWORD"
    test_own_cmd_success "rhsm registration with two aks" $SUDO subscription-manager register \
      --org="$RHSM_ORG" --activationkey="$RHSM_AK1,$RHSM_AK2" --name="$HOST" --force
    # we expect we have installed a product and can't auto subscribe
    test_own_cmd_exit_code 1 "rhsm auto subscribe" $SUDO subscription-manager subscribe --auto
    test_own_cmd_success "rhsm list all" $SUDO subscription-manager list --available --all
    POOLID=$(grab_pool_with_rhsm)
    test_own_cmd_success "rhsm subscribe to pool" $SUDO subscription-manager subscribe --pool "$POOLID"
    test_own_cmd_success "rhsm list" $SUDO subscription-manager list
    test_own_cmd_success "rhsm list available" $SUDO subscription-manager list --available
    test_own_cmd_success "rhsm list consumed" $SUDO subscription-manager list --consumed
    test_own_cmd_success "rhsm list ondate" $SUDO subscription-manager list --ondate=2011-09-15 --available
    test_own_cmd_success "rhsm list repos" $SUDO subscription-manager repos --list
    test_own_cmd_success "rhsm list service levels" $SUDO subscription-manager service-level --list
    test_own_cmd_success "rhsm refresh" $SUDO subscription-manager refresh
    test_own_cmd_success "rhsm unsubscribe all" $SUDO subscription-manager unsubscribe --all
    test_own_cmd_success "rhsm subscribe to pool" $SUDO subscription-manager subscribe --pool "$POOLID" # again
    SERIAL=$($SUDO subscription-manager list --consumed | sed 's/Serial Number/SerialNumber/g' | /usr/bin/perl -ne "print if /$RHSM_ZPROD/../^Serial/" | grep SerialNumber | head -n1 | awk '{print $2}') # grab first serial
    test_own_cmd_success "rhsm unsubscribe to serial" $SUDO subscription-manager unsubscribe --serial="$SERIAL"
    test_own_cmd_success "rhsm subscribe to pool" $SUDO subscription-manager subscribe --pool "$POOLID" # again
    test_own_cmd_success "rhsm unsubscribe all" $SUDO subscription-manager unsubscribe --all
    test_own_cmd_success "rhsm facts update" $SUDO subscription-manager facts --update
    test_own_cmd_success "rhsm unregister" $SUDO subscription-manager unregister

    # testing auto-unsubscribe
    test_own_cmd_success "rhsm registration with org" $SUDO subscription-manager register --username="$USER" \
        --password="$PASSWORD" --org="$RHSM_ORG" --force
    name1=$($SUDO subscription-manager identity | grep -o -E "^name:.*")
    name=${name1:6} # grab name
    test_success "system unregister in katello" system unregister --name="$name" --org="$RHSM_ORG"

    # ignore output from service restart: we don't care it says stopping failed
    # as long as the exit code is 0
    function restart_rhsmcertd { $SUDO service rhsmcertd restart &>/dev/null; }
    test_own_cmd_success "restart rhsmcrtd" restart_rhsmcertd
    test_own_cmd_failure "system is not registered" $SUDO subscription-manager identity

    # should cascade and delete everything
    test_success "org delete for rhsm" org delete --name="$RHSM_ORG"
  fi
else
  skip_test_success "rhsm registration" "subscription-manager command not found"
fi
