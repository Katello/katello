require 'katello/plugin.rb'

Foreman::Plugin.find(:katello).security_block :capsule_content do
  permission :manage_capsule_content,
             {
               'katello/api/v2/capsule_content' => [:lifecycle_environments, :available_lifecycle_environments, :add_lifecycle_environment, :remove_lifecycle_environment, :sync]
             },
             :resource_type => 'SmartProxy'
end
