#!/bin/bash

header "Katello Agent"

HOST=$(nospace "$(hostname)_$PLAIN_RAND")

INSTALL_PACKAGE=cheetah
INSTALL_GROUP=mammals
INSTALL_GROUP_PACKAGE=penguin
SYSTEM_GROUP_NAME="system_group_$RAND"

kt_agent_present() {
  rpm -q katello-agent &> /dev/null
  return $?
}

# testing registration from rhsm
if kt_agent_present; then
   cat <<EOF | $SUDO tee /etc/yum.repos.d/zoo.repo > /dev/null
[zoo-repo]
name=Zoo Repo
baseurl=http://tstrachota.fedorapeople.org/dummy_repos/zoo/
gpgcheck=0
EOF

  if grep 'hostname = subscription.rhn.redhat.com' /etc/rhsm/rhsm.conf; then
    skip_message "rhsm registration" "Could not test against hosted"
  else
    test_own_cmd_success "rhsm registration with org" $SUDO subscription-manager register --username="$USER" --password="$PASSWORD" \
      --org="$TEST_ORG" --environment "$TEST_ENV" --name="$HOST" --force
    # retrieve the system's uuid for later use
    identity=$($SUDO subscription-manager identity | grep -o -E "^Current identity is:.*")
    SYSTEM_UUID=${identity:21}

    echo "removing package "$INSTALL_PACKAGE" from the system"
    $SUDO yum remove -y "$INSTALL_PACKAGE" &> /dev/null
    test_success "remote system package install" system packages --install "$INSTALL_PACKAGE" --name "$HOST" --org "$TEST_ORG"
    test_own_cmd_success "package installed" rpm -q "$INSTALL_PACKAGE" &> /dev/null
    test_success "remote system package update" system packages --update "$INSTALL_PACKAGE" --name "$HOST" --org "$TEST_ORG"
    test_success "remote system package remove" system packages  --remove "$INSTALL_PACKAGE" --name "$HOST" --org "$TEST_ORG"
    test_own_cmd_failure "package unistalled" rpm -q "$INSTALL_PACKAGE" &> /dev/null

    echo "removing group "$INSTALL_GROUP" from the system"
    $SUDO yum groupremove -y "$INSTALL_GROUP" &> /dev/null
    test_success "remote system package group install" system packages --install_group "$INSTALL_GROUP" --name "$HOST" --org "$TEST_ORG"
    test_own_cmd_success "package group installed"  rpm -q "$INSTALL_GROUP_PACKAGE" &> /dev/null
    test_success "remote system package group remove" system packages  --remove_group "$INSTALL_GROUP" --name "$HOST" --org "$TEST_ORG"
    test_own_cmd_failure "package group uninstalled" rpm -q "$INSTALL_GROUP_PACKAGE" &> /dev/null

    # perform some tests on a system group
    test_success "system group create" system_group create --name "$SYSTEM_GROUP_NAME" --description "group description" --org "$TEST_ORG"
    test_success "add system to system group" system_group add_systems --system_uuids "$SYSTEM_UUID" --name "$SYSTEM_GROUP_NAME" --org "$TEST_ORG"

    echo "removing package "$INSTALL_PACKAGE" from the system"
    $SUDO yum remove -y "$INSTALL_PACKAGE" &> /dev/null
    test_success "remote system group package install" system_group packages --install "$INSTALL_PACKAGE" --name "$SYSTEM_GROUP_NAME" --org "$TEST_ORG"
    test_own_cmd_success "package installed" rpm -q "$INSTALL_PACKAGE" &> /dev/null
    test_success "remote system group package update" system_group packages --update "$INSTALL_PACKAGE" --name "$SYSTEM_GROUP_NAME" --org "$TEST_ORG"
    test_success "remote system group package remove" system_group packages  --remove "$INSTALL_PACKAGE" --name "$SYSTEM_GROUP_NAME" --org "$TEST_ORG"
    test_own_cmd_failure "package unistalled" rpm -q "$INSTALL_PACKAGE" &> /dev/null

    echo "removing group "$INSTALL_GROUP" from the system"
    $SUDO yum groupremove -y "$INSTALL_GROUP" &> /dev/null
    test_success "remote system group package group install" system_group packages --install_group "$INSTALL_GROUP" --name "$SYSTEM_GROUP_NAME" --org "$TEST_ORG"
    test_own_cmd_success "package group installed"  rpm -q "$INSTALL_GROUP_PACKAGE" &> /dev/null
    test_success "remote system group package group update" system_group packages --update_group "$INSTALL_GROUP" --name "$SYSTEM_GROUP_NAME" --org "$TEST_ORG"
    test_success "remote system group package group remove" system_group packages  --remove_group "$INSTALL_GROUP" --name "$SYSTEM_GROUP_NAME" --org "$TEST_ORG"
    test_own_cmd_failure "package group uninstalled" rpm -q "$INSTALL_GROUP_PACKAGE" &> /dev/null

    test_success "remove system from system group" system_group remove_systems --system_uuids "$SYSTEM_UUID" --name "$SYSTEM_GROUP_NAME" --org "$TEST_ORG"
    test_success "system group delete" system_group delete --name "$SYSTEM_GROUP_NAME" --org "$TEST_ORG"

    test_own_cmd_success "rhsm unregister" $SUDO subscription-manager unregister
  fi
  rm /etc/yum.repos.d/zoo.repo
else
  skip_message "katello-agent" "katello-agent not installed"
fi
