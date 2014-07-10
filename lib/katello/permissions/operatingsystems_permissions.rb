require 'katello/plugin.rb'

Foreman::AccessControl.permission(:view_operatingsystems).actions << [
  'operatingsystems/available_kickstart_repo'
]
