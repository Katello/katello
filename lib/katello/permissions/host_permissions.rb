require 'katello/plugin.rb'

Foreman::AccessControl.permission(:edit_hosts).actions.concat [
  'api/v2/hosts/host_collections',
  'katello/api/v2/host_errata/apply',
  'katello/api/v2/host_errata/applicability',
  'katello/api/v2/host_debs/auto_complete_search',
  'katello/api/v2/host_packages/install',
  'katello/api/v2/host_packages/upgrade',
  'katello/api/v2/host_packages/upgrade_all',
  'katello/api/v2/host_packages/remove',
  'katello/api/v2/host_packages/auto_complete_search',
  'katello/api/v2/host_subscriptions/auto_attach',
  'katello/api/v2/host_subscriptions/add_subscriptions',
  'katello/api/v2/host_subscriptions/remove_subscriptions',
  'katello/api/v2/host_subscriptions/available_release_versions',
  'katello/api/v2/host_subscriptions/content_override',
  'katello/api/v2/hosts_bulk_actions/bulk_add_host_collections',
  'katello/api/v2/hosts_bulk_actions/bulk_remove_host_collections',
  'katello/api/v2/hosts_bulk_actions/install_content',
  'katello/api/v2/hosts_bulk_actions/update_content',
  'katello/api/v2/hosts_bulk_actions/remove_content',
  'katello/api/v2/hosts_bulk_actions/add_subscriptions',
  'katello/api/v2/hosts_bulk_actions/remove_subscriptions',
  'katello/api/v2/hosts_bulk_actions/auto_attach',
  'katello/api/v2/hosts_bulk_actions/content_overrides',
  'katello/api/v2/hosts_bulk_actions/environment_content_view',
  'katello/api/v2/hosts_bulk_actions/release_version',
  'katello/api/v2/hosts_bulk_actions/traces',
  'katello/api/v2/hosts_bulk_actions/resolve_traces',
  'katello/api/v2/hosts_bulk_actions/system_purpose',
  'katello/api/v2/hosts_bulk_actions/change_content_source',
  'katello/api/rhsm/candlepin_dynflow_proxy/upload_package_profile',
  'katello/api/rhsm/candlepin_dynflow_proxy/upload_profiles',
  'katello/api/rhsm/candlepin_dynflow_proxy/deb_package_profile',
  'katello/api/rhsm/candlepin_proxies/regenerate_identity_certificates',
  'katello/api/rhsm/candlepin_proxies/hypervisors_update',
  'katello/api/rhsm/candlepin_proxies/async_hypervisors_update',
  'katello/api/rhsm/candlepin_proxies/hypervisors_heartbeat',
  'katello/api/rhsm/candlepin_proxies/upload_tracer_profile',
  'hosts/change_content_source_data'
]

Foreman::AccessControl.permission(:view_hosts).actions.concat [
  'hosts/content_hosts',
  'katello/api/v2/host_autocomplete/auto_complete_search',
  'katello/api/v2/host_errata/index',
  'katello/api/v2/host_errata/show',
  'katello/api/v2/host_errata/auto_complete_search',
  'katello/api/v2/host_module_streams/index',
  'katello/api/v2/host_module_streams/auto_complete_search',
  'katello/api/v2/host_subscriptions/index',
  'katello/api/v2/host_subscriptions/events',
  'katello/api/v2/host_subscriptions/product_content',
  'katello/api/v2/hosts_bulk_actions/applicable_errata',
  'katello/api/v2/hosts_bulk_actions/installable_errata',
  'katello/api/v2/hosts_bulk_actions/available_incremental_updates',
  'katello/api/v2/hosts_bulk_actions/module_streams',
  'katello/api/v2/host_debs/index',
  'katello/api/v2/host_packages/index',
  'katello/api/v2/host_tracer/index',
  'katello/api/v2/host_tracer/resolve',
  'katello/api/v2/host_tracer/auto_complete_search',
  'katello/remote_execution/new',
  'katello/remote_execution/create',
  'katello/api/v2/repository_sets/index',
  'katello/api/v2/repository_sets/auto_complete_search'
]

Foreman::AccessControl.permission(:destroy_hosts).actions.concat [
  'katello/api/v2/host_subscriptions/destroy',
  'katello/api/v2/hosts_bulk_actions/destroy_hosts'
]

Foreman::AccessControl.permission(:create_hosts).actions.concat [
  'katello/api/v2/host_subscriptions/create',
  'katello/api/rhsm/candlepin_proxies/consumer_create',
  'katello/api/rhsm/candlepin_proxies/consumer_show',
  'katello/api/rhsm/candlepin_proxies/hypervisors_update',
  'katello/api/rhsm/candlepin_proxies/async_hypervisors_update'
]
