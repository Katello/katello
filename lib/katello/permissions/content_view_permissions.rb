require 'katello/plugin.rb'

Foreman::Plugin.find(:katello).security_block :content_views do
  permission :view_content_views,
             {
                 'katello/api/v2/content_views' => [:index, :show, :history, :available_puppet_modules,
                                                    :available_puppet_module_names],
                 'katello/api/v2/content_view_filters' => [:index, :show, :available_errata,
                                                           :available_package_groups],
                 'katello/api/v2/content_view_filter_rules' => [:index, :show],
                 'katello/api/v2/content_view_puppet_modules' => [:index, :show],
                 'katello/api/v2/content_view_versions' => [:index, :show]
             },
             :resource_type => 'Katello::ContentView'
  permission :create_content_views,
             {
                 'katello/api/v2/content_views' => [:create],
                 'katello/api/v2/content_view_filters' => [:create],
                 'katello/api/v2/content_view_filter_rules' => [:create],
                 'katello/api/v2/content_view_puppet_modules' => [:create],
             },
             :resource_type => 'Katello::ContentView'
  permission :update_content_views,
             {
                 'katello/api/v2/content_views' => [:update],
                 'katello/api/v2/content_view_filters' => [:update],
                 'katello/api/v2/content_view_filter_rules' => [:update],
                 'katello/api/v2/content_view_puppet_modules' => [:update],
             },
             :resource_type => 'Katello::ContentView'
  permission :destroy_content_views,
             {
                 'katello/api/v2/content_views' => [:destroy, :remove],
                 'katello/api/v2/content_view_filters' => [:destroy],
                 'katello/api/v2/content_view_filter_rules' => [:destroy],
                 'katello/api/v2/content_view_puppet_modules' => [:destroy],
                 'katello/api/v2/content_view_versions' => [:destroy]
             },
             :resource_type => 'Katello::ContentView'
  permission :publish_content_views,
             {
                 'katello/api/v2/content_views' => [:publish]
             },
             :resource_type => 'Katello::ContentView'

  permission :promote_or_remove_content_views,
             {
                 'katello/api/v2/content_view_versions' => [:promote],
                 'katello/api/v2/content_views' => [:remove_from_environment, :remove]
             },
             :resource_type => 'Katello::ContentView'
end
