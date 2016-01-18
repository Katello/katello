require 'katello/plugin.rb'

Foreman::AccessControl.permission(:edit_hosts).actions << [
  'katello/api/v2/host_packages/install',
  'katello/api/v2/host_packages/upgrade',
  'katello/api/v2/host_packages/upgrade_all',
  'katello/api/v2/host_packages/remove'
]
