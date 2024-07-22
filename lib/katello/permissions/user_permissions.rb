require 'katello/plugin.rb'

Foreman::AccessControl.permission(:my_account).actions << [
  'katello/api/v2/tasks/show',
]
