#!/bin/bash


header "Compute resources"

if rpm -q foreman >> /dev/null; then

  #PROVIDERS=( "EC2" "LIBVIRT" "OPENSTACK" "OVIRT" "RACKSPACE" "VMWARE" )
  PROVIDERS=( "LIBVIRT" "OVIRT" "RACKSPACE" )
  OPENSTACK_OPTS="--user=user --password=passwd --tenant=tenant"
  OVIRT_OPTS="--user=user --password=passwd --uuid=uuid"
  VMWARE_OPTS="--user=user --password=passwd --uuid=uuid --server=server"
  EC2_OPTS="--user=user --password=passwd --region=region"
  RACKSPACE_OPTS="--user=user --password=passwd --region=ORD"

  COMP_RES_URL="https://some.url"

  #create a provider of each type and try to get it's info
  for p in "${PROVIDERS[@]}"; do
  	opts_name="${p}_OPTS"
	  test_success "compute_resource create $p" compute_resource create --name="${p}_${RAND}" --provider="$p" --url="$COMP_RES_URL" ${!opts_name}
	  test_success "compute_resource info $p" compute_resource info --name="${p}_${RAND}"
	done

	test_success "compute_resource list" compute_resource list

  #update resource's name there and back
  CR_NAME="LIBVIRT_$RAND"
  NEW_CR_NAME="LIBVIRT_2_$RAND"
	test_success "compute_resource update" compute_resource update --name="$CR_NAME" --new_name="$NEW_CR_NAME"
	test_success "compute_resource update" compute_resource update --name="$NEW_CR_NAME" --new_name="$CR_NAME"

	#delete all providers
	for p in "${PROVIDERS[@]}"; do
		test_success "compute_resource delete $p" compute_resource delete --name="${p}_${RAND}"
	done


else
	skip_message "compute resources" "Foreman not installed, skipping compute resources tests"
fi
