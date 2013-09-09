class DbUniqueIndices < ActiveRecord::Migration
  def self.up
    add_index(:activation_keys, [:name, :organization_id], :unique => true)
    add_index(:changesets, [:name, :environment_id], :unique => true)
    add_index(:changeset_distributions, [:distribution_id, :changeset_id], :name => "index_cs_distro_distro_id_cs_id", :unique => true)

    add_index(:changeset_errata, [:errata_id, :changeset_id], :unique => true)
    add_index(:changeset_packages, [:nvrea, :changeset_id], :unique => true)

    add_index(:environments, [:name, :organization_id], :unique => true)
    add_index(:ldap_group_roles, [:ldap_group, :role_id], :unique => true)
    add_index(:organizations, :name, :unique => true)
    add_index(:organizations, :cp_key, :unique => true)

    add_index(:permissions, [:name, :organization_id, :role_id], :unique => true)
    add_index(:providers, [:name, :organization_id], :unique => true)
    add_index(:roles, :name, :unique => true)
    add_index(:roles_users, [:user_id, :role_id], :unique => true)
    add_index(:sync_plans, [:name, :organization_id], :unique => true)
    add_index(:system_groups, [:name, :organization_id], :unique => true)
    add_index(:system_templates, [:name, :environment_id], :unique => true)
    add_index(:system_template_distributions, [:distribution_pulp_id, :system_template_id], :name => "index_sys_template_distro_on_pulp_id_template_id", :unique => true)
    add_index(:system_template_packages, [:system_template_id, :package_name, :version, :release, :epoch, :arch], :unique => true, :name => "index_sys_template_packages_on_nvrea_template_id")
    add_index(:system_template_pack_groups, [:name, :system_template_id], :name => "index_sys_template_packs_on_name_template_id",  :unique => true)
    add_index(:system_template_pg_categories, [:name, :system_template_id], :name => "index_sys_template_pg_categories_on_name_template_id", :unique => true)

    add_index(:users, :username, :unique => true)
  end

  def self.down
    remove_index(:activation_keys, :column => [:name, :organization_id])
    remove_index(:changesets, :column => [:name, :environment_id])
    remove_index(:changeset_distributions, :name => "index_cs_distro_distro_id_cs_id")
    remove_index(:changeset_errata, [:errata_id, :changeset_id])
    remove_index(:changeset_packages, [:nvrea, :changeset_id])

    remove_index(:environments, :column => [:name, :organization_id])
    remove_index(:ldap_group_roles, :column => [:ldap_group, :role_id])
    remove_index(:organizations, :name)
    remove_index(:organizations, :cp_key)

    remove_index(:permissions, :column => [:name, :organization_id, :role_id])
    remove_index(:providers, :column => [:name, :organization_id])
    remove_index(:roles, :name)
    remove_index(:roles_users, :column => [:user_id, :role_id])
    remove_index(:sync_plans, :column => [:name, :organization_id])
    remove_index(:system_groups, :column => [:name, :organization_id])
    remove_index(:system_templates, :column => [:name, :environment_id])
    remove_index(:system_template_distributions, :name => "index_sys_template_distro_on_pulp_id_template_id")
    remove_index(:system_template_packages, :name => "index_sys_template_packages_on_nvrea_template_id")
    remove_index(:system_template_pack_groups, :name => "index_sys_template_packs_on_name_template_id")
    remove_index(:system_template_pg_categories, :name => "index_sys_template_pg_categories_on_name_template_id")
    remove_index(:users, :username)
  end
end
