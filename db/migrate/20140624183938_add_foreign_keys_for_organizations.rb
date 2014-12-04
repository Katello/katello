class AddForeignKeysForOrganizations < ActiveRecord::Migration
  def up
    add_foreign_key(:katello_task_statuses, :taxonomies,
                    :name => 'katello_task_statuses_organization_fk', :column => 'organization_id')
    add_foreign_key(:katello_sync_plans, :taxonomies,
                    :name => 'katello_sync_plans_organization_fk', :column => 'organization_id')
    add_foreign_key(:katello_providers, :taxonomies,
                    :name => 'katello_providers_organization_fk', :column => 'organization_id')
    add_foreign_key(:katello_gpg_keys, :taxonomies,
                    :name => 'katello_gpg_keys_organization_fk', :column => 'organization_id')
    add_foreign_key(:katello_products, :taxonomies,
                    :name => 'katello_products_organization_fk', :column => 'organization_id')
    add_foreign_key(:katello_activation_keys, :taxonomies,
                    :name => 'katello_activation_keys_organization_fk', :column => 'organization_id')
    add_foreign_key(:katello_notices, :taxonomies,
                    :name => 'katello_notices_organization_fk', :column => 'organization_id')
    add_foreign_key(:katello_host_collections, :taxonomies,
                    :name => 'katello_host_collections_organization_fk', :column => 'organization_id')
    add_foreign_key(:katello_environments, :taxonomies,
                    :name => 'katello_environments_organization_fk', :column => 'organization_id')
  end

  def down
    remove_foreign_key('katello_task_statuses', :name => 'katello_task_statuses_organization_fk')
    remove_foreign_key('katello_sync_plans', :name => 'katello_sync_plans_organization_fk')
    remove_foreign_key('katello_providers', :name => 'katello_providers_organization_fk')
    remove_foreign_key('katello_gpg_keys', :name => 'katello_gpg_keys_organization_fk')
    remove_foreign_key('katello_products', :name => 'katello_products_organization_fk')
    remove_foreign_key('katello_activation_keys', :name => 'katello_activation_keys_organization_fk')
    remove_foreign_key('katello_notices', :name => 'katello_notices_organization_fk')
    remove_foreign_key('katello_host_collections', :name => 'katello_host_collections_organization_fk')
    remove_foreign_key('katello_environments', :name => 'katello_environments_organization_fk')
  end
end
