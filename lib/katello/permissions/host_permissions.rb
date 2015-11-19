require 'katello/plugin.rb'

Foreman::AccessControl.permission(:edit_hosts).actions << [
  'api/v2/hosts/host_collections'
]
