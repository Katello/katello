#!/bin/bash
# this also tests ability to intall imported products

header "provider import"

if [ -e /etc/redhat-release ]; then
  RELEASEVER=$(rpm -qf /etc/redhat-release --queryformat '%{VERSION}' | sed 's/6Server/6.2/g' | sed 's/5Server/5.7/g')
fi
if [[ -z "$RELEASEVER" ]]; then
  RELEASEVER=16
fi

MANIFEST_ORG="org_manifest_$RAND"
MANIFEST_ENV="env_manifest_$RAND"
MANIFEST_AK1=$(nospace "manifest_ak1_$RAND")
MANIFEST_AK2=$(nospace "manifest_ak2_$RAND")
CS1_NAME="changeset_manifest_$RAND"
MANIFEST_PATH="$TESTDIR/fake-manifest-syncable.zip"
MANIFEST_REPO_URL="http://inecas.fedorapeople.org/fakerepos/cds/"
MANIFEST_EPROD="Zoo Enterprise"
MANIFEST_PROD="Zoo Enterprise 247"
MANIFEST_PROD_CP="Zoo Enterprise 24/7"
MANIFEST_REPO="Zoo Enterprise x86_64 $RELEASEVER"
MANIFEST_REPO_LABEL="zoo-enterprise"
INSTALL_PACKAGE=cheetah
SLA="SELF-SUPPORT"
HOST=$(nospace "$(hostname)_$RAND")



test_success "org create for manifest ($MANIFEST_ORG)" org create --name="$MANIFEST_ORG" --description="org for rhsm"
test_success "env create for manifest ($MANIFEST_ENV)" environment create --org="$MANIFEST_ORG" --name="$MANIFEST_ENV" --prior Library
test_success "update provider url" provider update --name "Red Hat" --org "$MANIFEST_ORG" --url "$MANIFEST_REPO_URL"
test_success "import manifest" provider import_manifest --name "Red Hat" --org "$MANIFEST_ORG" --file "$MANIFEST_PATH" --force
test_success "products refresh" provider refresh_products --name "Red Hat" --org "$MANIFEST_ORG"
test_success "repo enable" repo enable --name="$MANIFEST_REPO" --product "$MANIFEST_EPROD" --org "$MANIFEST_ORG"
test_success "repo synchronize" repo synchronize --name="$MANIFEST_REPO" --product "$MANIFEST_EPROD" --org "$MANIFEST_ORG"
test_success "changeset create" changeset create --org="$MANIFEST_ORG" --environment="$MANIFEST_ENV" --name="$CS1_NAME"
test_success "changeset add product" changeset update  --org="$MANIFEST_ORG" --environment="$MANIFEST_ENV" --name="$CS1_NAME" --add_product="$MANIFEST_EPROD"
check_delayed_jobs_running
test_success "changeset promote" changeset promote --org="$MANIFEST_ORG" --environment="$MANIFEST_ENV" --name="$CS1_NAME"
POOLID=$($CMD org subscriptions --name "$MANIFEST_ORG" -g -d ";" | grep "$MANIFEST_PROD_CP" | awk -F ' *; *' '{print $4}') # grab a pool for CP

test_success "system register with SLA" system register --name="$HOST" --org="$MANIFEST_ORG" --environment="$MANIFEST_ENV" --servicelevel="$SLA"
test_success "system update SLA" system update --name="$HOST" --org="$MANIFEST_ORG" --servicelevel="$SLA"
test_success "system unregister" system unregister --name="$HOST"  --org="$MANIFEST_ORG"


sm_present() {
  which subscription-manager &> /dev/null
  return $?
}

# testing registration from rhsm
if sm_present; then
  test_own_cmd_success "rhsm registration with org" sudo subscription-manager register --username="$USER" --password="$PASSWORD" \
    --org="$MANIFEST_ORG" --name="$HOST" --force
  test_own_cmd_success "rhsm subscribe to pool" sudo subscription-manager subscribe --pool "$POOLID"
  sudo yum remove -y "$INSTALL_PACKAGE" &> /dev/null
  test_own_cmd_success "install package from subscribed product" sudo yum install -y "$INSTALL_PACKAGE" --nogpgcheck --releasever "$RELEASEVER" --disablerepo \* --enablerepo "$MANIFEST_REPO_LABEL"
  sudo yum remove -y "$INSTALL_PACKAGE" &> /dev/null
  test_own_cmd_success "rhsm set releasever" sudo subscription-manager release --set "$RELEASEVER"
  test_own_cmd_success "install package from subscribed product after set releasever" sudo yum install -y "$INSTALL_PACKAGE" --nogpgcheck
  sudo yum remove -y "$INSTALL_PACKAGE" &> /dev/null
  test_own_cmd_success "rhsm unsubscribe all" sudo subscription-manager unsubscribe --all
  test_own_cmd_success "rhsm unregister" sudo subscription-manager unregister

  test_own_cmd_success "rhsm list available SLAs" sudo subscription-manager service-level --list --org="$MANIFEST_ORG"  --username="$USER" --password="$PASSWORD"
  test_own_cmd_exit_code 1 "rhsm registration with SLA" sudo subscription-manager register --username="$USER" --password="$PASSWORD" \
    --org="$MANIFEST_ORG" --name="$HOST" --servicelevel="$SLA" --autosubscribe --force
  test_own_cmd_success "rhsm unregister" sudo subscription-manager unregister

else
  skip_test_success "rhsm registration" "subscription-manager command not found"
fi
test_success "org delete for manifest" org delete --name="$MANIFEST_ORG"
