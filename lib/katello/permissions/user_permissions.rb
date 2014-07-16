require 'katello/plugin.rb'

Foreman::Plugin.find(:katello).security_block :user do
  permission :my_organizations,
             {
              'katello/api/rhsm/candlepin_proxies' => [:list_owners]
             },
             :public => true
end

Foreman::AccessControl.permission(:my_account).actions << [
  'katello/api/v2/tasks/show'
]
