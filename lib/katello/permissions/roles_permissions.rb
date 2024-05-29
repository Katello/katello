require 'katello/plugin.rb'

Foreman::AccessControl.permission(:edit_roles).actions.concat [
  'katello/auto_complete_search/auto_complete_search',
]
