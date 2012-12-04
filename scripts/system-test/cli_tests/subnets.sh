#!/bin/bash

header "Subnet"

SUBNET_NAME="subnet_$RAND"
NEW_SUBNET_NAME="new_$SUBNET_NAME"
SUBNET_NAME_2="subnet_2_$RAND"

test_success "subnet list" subnet list
test_success "subnet create" subnet create --name="$SUBNET_NAME" --network 168.192.122.13 --mask 255.255.0.0
test_success "subnet create with all details" subnet create \
    --name="$SUBNET_NAME_2" --network=168.192.122.14 --mask=255.255.0.0 \
    --dns_primary=168.192.83.32 --dns_secondary=168.192.83.33 \
    --gateway=168.192.83.34 --from=168.192.122.0 --to=168.192.122.255
#TODO:
# add missing parameters once their CRUD actions are implemented in katello cli
#   --vlanid=VLANID          VLAN ID for this subnet
#   --domain_ids=DOMAIN_IDS  Domains in which this subnet is part
#   --dhcp_id=DHCP_ID        DHCP Proxy to use within this subnet  \
#   --tftp_id=TFTP_ID        TFTP Proxy to use within this subnet  |- smart proxies
#   --dns_id=DNS_ID          DNS Proxy to use within this subnet  /


test_success "subnet info" subnet info --name="$SUBNET_NAME"
test_success "subnet update" subnet update --name="$SUBNET_NAME" --new_name="$NEW_SUBNET_NAME" --network 168.192.122.13 --mask 255.255.0.0
test_success "subnet info" subnet info --name="$NEW_SUBNET_NAME"
test_success "subnet delete" subnet delete --name="$NEW_SUBNET_NAME"
test_success "subnet delete" subnet delete --name="$SUBNET_NAME_2"


