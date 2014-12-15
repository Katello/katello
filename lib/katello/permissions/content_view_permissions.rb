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
               'katello/api/v2/content_view_versions' => [:index, :show],
               'katello/api/v2/package_groups' => [:index, :show],
               'katello/api/v2/errata' => [:index, :show],
               'katello/api/v2/puppet_modules' => [:index, :show],
               'katello/content_views' => [:auto_complete, :auto_complete_search],
               'katello/errata' => [:short_details, :auto_complete],
               'katello/packages' => [:details, :auto_complete],
               'katello/products' => [:auto_complete],
               'katello/repositories' => [:auto_complete_library],
               'katello/content_search' => [:index,
                                            :products,
                                            :repos,
                                            :packages,
                                            :errata,
                                            :puppet_modules,
                                            :packages_items,
                                            :errata_items,
                                            :puppet_modules_items,
                                            :view_packages,
                                            :view_puppet_modules,
                                            :repo_packages,
                                            :repo_errata,
                                            :repo_puppet_modules,
                                            :repo_compare_errata,
                                            :repo_compare_packages,
                                            :repo_compare_puppet_modules,
                                            :view_compare_errata,
                                            :view_compare_packages,
                                            :view_compare_puppet_modules,
                                            :views],
               'katello/dashboard' => [:content_views, :promotions]
             },
             :resource_type => 'Katello::ContentView'
  permission :create_content_views,
             {
               'katello/api/v2/content_views' => [:create, :copy]
             },
             :resource_type => 'Katello::ContentView'
  permission :edit_content_views,
             {
               'katello/api/v2/content_views' => [:update],
               'katello/api/v2/content_view_filters' => [:create, :update, :destroy],
               'katello/api/v2/content_view_filter_rules' => [:create, :update, :destroy],
               'katello/api/v2/content_view_puppet_modules' => [:create, :update, :destroy]
             },
             :resource_type => 'Katello::ContentView'
  permission :destroy_content_views,
             {
               'katello/api/v2/content_views' => [:destroy, :remove],
               'katello/api/v2/content_view_versions' => [:destroy]
             },
             :resource_type => 'Katello::ContentView'
  permission :publish_content_views,
             {
               'katello/api/v2/content_views' => [:publish],
               'katello/api/v2/content_view_versions' => [:incremental_update]
             },
             :resource_type => 'Katello::ContentView'
  permission :promote_or_remove_content_views,
             {
               'katello/api/v2/content_view_versions' => [:promote],
               'katello/api/v2/content_views' => [:remove_from_environment, :remove]
             },
             :resource_type => 'Katello::ContentView'
end
