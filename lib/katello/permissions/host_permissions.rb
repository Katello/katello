require 'katello/plugin.rb'

Foreman::AccessControl.permission(:edit_hosts).actions.concat [
  'api/v2/hosts/host_collections',
  'katello/api/v2/host_errata/apply',
  'katello/api/v2/host_errata/applicability',
  'katello/api/v2/host_packages/install',
  'katello/api/v2/host_packages/upgrade',
  'katello/api/v2/host_packages/upgrade_all',
  'katello/api/v2/host_packages/remove',
  'katello/api/v2/host_subscriptions/auto_attach',
  'katello/api/v2/host_subscriptions/add_subscriptions',
  'katello/api/v2/host_subscriptions/remove_subscriptions',
  'katello/api/v2/host_subscriptions/content_override',
  'katello/api/v2/hosts_bulk_actions/bulk_add_host_collections',
  'katello/api/v2/hosts_bulk_actions/bulk_remove_host_collections',
  'katello/api/v2/hosts_bulk_actions/install_content',
  'katello/api/v2/hosts_bulk_actions/update_content',
  'katello/api/v2/hosts_bulk_actions/remove_content',
  'katello/api/v2/hosts_bulk_actions/environment_content_view',
  'katello/api/rhsm/candlepin_proxies/upload_package_profile',
  'katello/api/rhsm/candlepin_proxies/regenerate_identity_certificates',
  'katello/api/rhsm/candlepin_proxies/hypervisors_update'
]

Foreman::AccessControl.permission(:view_hosts).actions.concat [
  'hosts/puppet_environment_for_content_view',
  'katello/api/v2/host_autocomplete/auto_complete_search',
  'katello/api/v2/host_errata/index',
  'katello/api/v2/host_errata/show',
  'katello/api/v2/host_errata/auto_complete_search',
  'katello/api/v2/host_subscriptions/index',
  'katello/api/v2/host_subscriptions/events',
  'katello/api/v2/host_subscriptions/product_content',
  'katello/api/v2/hosts_bulk_actions/installable_errata',
  'katello/api/v2/hosts_bulk_actions/available_incremental_updates',
  'katello/api/v2/host_packages/index'
]

Foreman::AccessControl.permission(:destroy_hosts).actions.concat [
  'katello/api/v2/host_subscriptions/destroy',
  'katello/api/v2/hosts_bulk_actions/destroy_hosts'
]

Foreman::AccessControl.permission(:create_hosts).actions.concat [
  'katello/api/v2/host_subscriptions/create',
  'katello/api/rhsm/candlepin_proxies/consumer_create',
  'katello/api/rhsm/candlepin_proxies/consumer_show',
  'katello/api/rhsm/candlepin_proxies/hypervisors_update'
]
