#!/bin/bash


header "Partition Table"

if foreman_installed; then

	PTABLE_NAME="a_$RAND"
	NEW_PTABLE_NAME="b_$RAND"
	PTABLE_FILE="/tmp/fake_ptable_$RAND"

	echo "some layout" > $PTABLE_FILE

	#testing partition tables
	test_success "partition_table create" partition_table create --name="$PTABLE_NAME" --layout_file="$PTABLE_FILE" --os_family='Redhat'
	test_success "partition_table info"   partition_table info --name="$PTABLE_NAME"
	test_success "partition_table update" partition_table update --name="$PTABLE_NAME" --new_name="$NEW_PTABLE_NAME" --layout_file="$PTABLE_FILE"
	test_success "partition_table list"   partition_table list
	test_failure "partition_table try to delete old name" partition_table delete --name="$PTABLE_NAME"
	test_success "partition_table delete" partition_table delete --name="$NEW_PTABLE_NAME"

	rm $PTABLE_FILE

else
	skip_message "partition_table" "Foreman not installed, skipping partition table tests"
fi
