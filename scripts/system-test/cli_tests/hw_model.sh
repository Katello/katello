#!/bin/bash


header "Hardware Models"

if rpm -q foreman >> /dev/null; then

	HW_MODEL_NAME="hw_model_a_$RAND"
	HW_MODEL_NAME_2="hw_model_b_$RAND"
	NEW_HW_MODEL_NAME="hw_model_a2_$RAND"

	#testing hardware models
	test_success "hw_model create" hw_model create --name="$HW_MODEL_NAME"
	test_success "hw_model create with deatils" hw_model create --name="$HW_MODEL_NAME_2" --info="model info" --vendor_class="model vendor class"  --hw_model="hardware model"
	test_success "hw_model info"   hw_model info   --name="$HW_MODEL_NAME"
	test_success "hw_model update" hw_model update --name="$HW_MODEL_NAME" --new_name="$NEW_HW_MODEL_NAME"
	test_success "hw_model list"   hw_model list
	test_failure "hw_model try to delete old name" hw_model delete --name="$HW_MODEL_NAME"
	test_success "hw_model delete" hw_model delete --name="$NEW_HW_MODEL_NAME"
else
	skip_message "hw_model" "Foreman not installed, skipping hw_model tests"
fi
