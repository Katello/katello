#!/bin/bash

header "Katello Agent"

HOST=$(nospace "$(hostname)_$PLAIN_RAND")

INSTALL_PACKAGE=cheetah
INSTALL_GROUP=mammals
INSTALL_GROUP_PACKAGE=penguin

kt_agent_present() {
  rpm -q katello-agent &> /dev/null
  return $?
}

# testing registration from rhsm
if kt_agent_present; then
   cat <<EOF | sudo tee /etc/yum.repos.d/zoo.repo > /dev/null
[zoo-repo]
name=Zoo Repo
baseurl=http://tstrachota.fedorapeople.org/dummy_repos/zoo/
gpgcheck=0
EOF

  test_own_cmd_success "rhsm registration with org" sudo subscription-manager register --username="$USER" --password="$PASSWORD" \
    --org="$TEST_ORG" --environment "$TEST_ENV" --name="$HOST" --force

  echo "removing package "$INSTALL_PACKAGE" from the system"
  sudo yum remove -y "$INSTALL_PACKAGE" &> /dev/null
  test_success "remote package install" system packages --install "$INSTALL_PACKAGE" --name "$HOST" --org "$TEST_ORG"
  test_own_cmd_success "package installed" rpm -q "$INSTALL_PACKAGE" &> /dev/null
  test_success "remote package update" system packages --update "$INSTALL_PACKAGE" --name "$HOST" --org "$TEST_ORG"
  test_success "remote package remove" system packages  --remove "$INSTALL_PACKAGE" --name "$HOST" --org "$TEST_ORG"
  test_own_cmd_failure "package unistalled" rpm -q "$INSTALL_PACKAGE" &> /dev/null

  echo "removing group "$INSTALL_GROUP" from the system"
  sudo yum groupremove -y "$INSTALL_GROUP" &> /dev/null
  test_success "remote package group install" system packages --install_group "$INSTALL_GROUP" --name "$HOST" --org "$TEST_ORG"
  test_own_cmd_success "package group installed"  rpm -q "$INSTALL_GROUP_PACKAGE" &> /dev/null
  test_success "remote package group remove" system packages  --remove_group "$INSTALL_GROUP" --name "$HOST" --org "$TEST_ORG"
  test_own_cmd_failure "package group uninstalled" rpm -q "$INSTALL_GROUP_PACKAGE" &> /dev/null

  test_own_cmd_success "rhsm unregister" sudo subscription-manager unregister

  rm /etc/yum.repos.d/zoo.repo
else
  skip_test_success "katello-agent" "katello-agent not installed"
fi
