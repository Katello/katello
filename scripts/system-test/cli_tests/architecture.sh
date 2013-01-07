#!/bin/bash


header "Architectures"

if rpm -q foreman >> /dev/null; then

	ARCH_NAME="a_${RAND:0:5}"
	NEW_ARCH_NAME="b_${RAND:0:5}"

	#testing architectures
	test_success "architecture create" architecture create --name="$ARCH_NAME"
	test_success "architecture info" architecture info --name="$ARCH_NAME"
	test_success "architecture update" architecture update --name="$ARCH_NAME" --new_name="$NEW_ARCH_NAME"
	test_success "architecture list" architecture list
	test_failure "architecture try to delete old name" architecture delete --name="$ARCH_NAME"
	test_success "architecture delete" architecture delete --name="$NEW_ARCH_NAME"
else
	skip_message "architectures" "Foreman not installed, skipping architecture tests"
fi
