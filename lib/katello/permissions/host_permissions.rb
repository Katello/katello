require 'katello/plugin.rb'

Foreman::AccessControl.permission(:edit_hosts).actions << [
  'api/v2/hosts/host_collections',
  'katello/api/v2/host_errata/apply',
  'katello/api/v2/host_packages/install',
  'katello/api/v2/host_packages/upgrade',
  'katello/api/v2/host_packages/upgrade_all',
  'katello/api/v2/host_packages/remove',
  'katello/api/v2/host_subscriptions/auto_attach',
  'katello/api/v2/host_subscriptions/add_subscriptions',
  'katello/api/v2/host_subscriptions/remove_subscriptions',
  'katello/api/v2/hosts_bulk_actions/bulk_add_host_collections',
  'katello/api/v2/hosts_bulk_actions/bulk_remove_host_collections',
  'katello/api/v2/hosts_bulk_actions/install_content',
  'katello/api/v2/hosts_bulk_actions/update_content',
  'katello/api/v2/hosts_bulk_actions/remove_content',
  'katello/api/v2/hosts_bulk_actions/environment_content_view'
]

Foreman::AccessControl.permission(:view_hosts).actions << [
  'katello/api/v2/host_errata/index',
  'katello/api/v2/host_errata/show',
  'katello/api/v2/host_subscriptions/index',
  'katello/api/v2/host_subscriptions/events',
  'katello/api/v2/hosts_bulk_actions/installable_errata'

]

Foreman::AccessControl.permission(:destroy_hosts).actions << [
  'katello/api/v2/hosts_bulk_actions/destroy_hosts'
]
