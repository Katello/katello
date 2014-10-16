require 'katello/plugin.rb'

Foreman::AccessControl.permission(:access_dashboard).actions << [
  'katello/dashboard/index',
  'katello/dashboard/notices'
]
