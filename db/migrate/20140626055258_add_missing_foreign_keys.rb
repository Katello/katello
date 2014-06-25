class AddMissingForeignKeys < ActiveRecord::Migration
  def up
    add_foreign_key(:katello_capsule_lifecycle_environments, :smart_proxies,
                    :name => 'katello_capsule_lifecycle_environments_capsule_fk', :column => 'capsule_id')
    add_foreign_key(:katello_capsule_lifecycle_environments, :katello_environments,
                    :name => 'katello_capsule_lifecycle_environments_environment_fk', :column => 'lifecycle_environment_id')
    add_foreign_key(:katello_repositories, :katello_environments,
                    :name => 'katello_repositories_environment_fk', :column => 'environment_id')
    add_foreign_key(:katello_repositories, :katello_products,
                    :name => 'katello_repositories_product_fk', :column => 'product_id')
  end

  def down
    remove_foreign_key('katello_capsule_lifecycle_environments', :name => 'katello_capsule_lifecycle_environments_capsule_fk')
    remove_foreign_key('katello_capsule_lifecycle_environments', :name => 'katello_capsule_lifecycle_environments_environment_fk')
    remove_foreign_key('katello_repositories', :name => 'katello_repositories_environment_fk')
    remove_foreign_key('katello_repositories', :name => 'katello_repositories_product_fk')
  end
end
