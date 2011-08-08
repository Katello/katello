#!/bin/bash

# testing registration from rhsm
(which subscription-manager 2>/dev/null && \
  test_own_cmd "rhsm registration" sudo subscription-manager register --username=$USER --password=$PASSWORD \
  --org=$FIRST_ORG --environment=$TEST_ENV_3 --name=$HOSTNAME --force) || \
  skip_test "rhsm registration" "subscription-manager command not found"
