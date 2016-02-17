require 'katello/plugin.rb'

Foreman::AccessControl.permission(:view_operatingsystems).actions.concat [
  'operatingsystems/available_kickstart_repo'
]
