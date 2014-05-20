require 'katello/plugin.rb'

Foreman::Plugin.find(:katello).security_block :products do
  permission :view_products,
             {
               'katello/products' => [:auto_complete],
               'katello/api/v2/products' => [:index, :show],
               'katello/api/v2/repositories' => [:index, :show],
               'katello/errata' => [:short_details, :auto_complete],
               'katello/packages' => [:details, :auto_complete],
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
                                            :repo_packages,
                                            :repo_errata,
                                            :repo_puppet_modules,
                                            :repo_compare_errata,
                                            :repo_compare_packages,
                                            :repo_compare_puppet_modules]
               },
             :resource_type => 'Katello::Product'
  permission :create_products,
             {
               'katello/api/v2/products' => [:create],
               'katello/api/v2/repositories' => [:create]
             },
             :resource_type => 'Katello::Product'
  permission :update_products,
             {
               'katello/api/v2/products' => [:update],
               'katello/api/v2/repositories' => [:update],
               'katello/api/v2/products_bulk_actions' => [:update_sync_plans],
               'katello/api/v2/content_uploads' => [:create, :upload_bits, :import_into_repo, :upload_file, :destroy],
               'katello/api/v2/organizations' => [:repo_discover, :cancel_repo_discover]
             },
             :resource_type => 'Katello::Product'
  permission :destroy_products,
             {
               'katello/api/v2/products' => [:destroy],
               'katello/api/v2/repositories' => [:destroy],
               'katello/api/v2/products_bulk_actions' => [:destroy_products],
               'katello/api/v2/repositories_bulk_actions' => [:destroy_repositories]
             },
             :resource_type => 'Katello::Product'
  permission :sync_products,
             {
               'katello/api/v2/products' => [:sync],
               'katello/api/v2/repositories' => [:sync],
               'katello/api/v2/products_bulk_actions' => [:sync_products],
               'katello/api/v2/repositories_bulk_actions' => [:sync_repositories],
               'katello/api/v2/sync' => [:index],
               'katello/sync_management' => [:index, :sync_status, :product_status, :sync, :destroy],
               'katello/dashboard' => [:sync]
             },
             :resource_type => 'Katello::Product'
end
