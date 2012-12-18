#!/bin/bash


header "Smart Proxies"

if rpm -q foreman >> /dev/null; then

	export SMART_PROXY_LOCATION
	if [ "$SMART_PROXY_LOCATION" != "" ]; then

		PROXY_NAME="proxy_$RAND"
		NEW_PROXY_NAME="another_$PROXY_NAME"
		PROXY_URL="$SMART_PROXY_LOCATION"

		test_success "smart_proxy create" smart_proxy create --name="$PROXY_NAME" --url="$PROXY_URL"
		test_success "smart_proxy info" smart_proxy info --name="$PROXY_NAME"
		test_success "smart_proxy update" smart_proxy update --name="$PROXY_NAME" --new_name="$NEW_PROXY_NAME"
		test_success "smart_proxy list" smart_proxy list
		test_failure "smart_proxy try to delete old name" smart_proxy delete --name="$PROXY_NAME"
		test_success "smart_proxy delete" smart_proxy delete --name="$NEW_PROXY_NAME"

	else
		skip_message \
			"smart proxies" \
			"Environment variable \$SMART_PROXY_LOCATION must be set to a real instance of a smart proxy, starting with 'http://' or 'https://'"
	fi

else
	skip_message "smart proxies" "Foreman not installed, skipping smart proxies tests"
fi
