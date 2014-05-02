require 'katello/plugin.rb'

Foreman::Plugin.find(:katello).security_block :products do
  permission :view_products,
             {
               'katello/products' => [:all, :index],
               'katello/api/v2/products' => [:index, :show],
               'katello/api/v2/repositories' => [:index, :show]
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
               'katello/api/v2/repositories_bulk_actions' => [:sync_repositories]
             },
             :resource_type => 'Katello::Product'
end
