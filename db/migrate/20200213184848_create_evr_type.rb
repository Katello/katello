require 'fx'

class CreateEvrType < ActiveRecord::Migration[5.2]
  def up
    unless connection.adapter_name.downcase.include?('sqlite')

      enable_extension "evr"

      add_column :katello_rpms, :evr, :evr_t
      add_column :katello_installed_packages, :evr, :evr_t

      create_trigger :evr_insert_trigger_katello_rpms, on: :katello_rpms
      create_trigger :evr_update_trigger_katello_rpms, on: :katello_rpms
      create_trigger :evr_insert_trigger_katello_installed_packages, on: :katello_installed_packages
      create_trigger :evr_update_trigger_katello_installed_packages, on: :katello_installed_packages

      execute <<-SQL
        update katello_rpms SET evr = (ROW(coalesce(epoch::numeric,0),
                                           rpmver_array(coalesce(version,'empty'))::evr_array_item[],
                                           rpmver_array(coalesce(release,'empty'))::evr_array_item[])::evr_t);

        update katello_installed_packages SET evr = (ROW(coalesce(epoch::numeric,0),
                                                         rpmver_array(coalesce(version,'empty'))::evr_array_item[],
                                                         rpmver_array(coalesce(release,'empty'))::evr_array_item[])::evr_t);
      SQL

      add_index :katello_rpms, [:name, :arch, :evr]
      add_index :katello_erratum_packages, [:erratum_id, :nvrea]
    end
  end

  def down
    # fx doesn't seem to have support for dropping functions with parameters
    unless connection.adapter_name.downcase.include?('sqlite')
      remove_index :katello_rpms, column: [:name, :arch, :evr]
      remove_index :katello_erratum_packages, column: [:erratum_id, :nvrea]

      drop_trigger :evr_insert_trigger_katello_rpms, on: :katello_rpms
      drop_trigger :evr_update_trigger_katello_rpms, on: :katello_rpms
      drop_trigger :evr_insert_trigger_katello_installed_packages, on: :katello_installed_packages
      drop_trigger :evr_update_trigger_katello_installed_packages, on: :katello_installed_packages

      remove_column :katello_rpms, :evr
      remove_column :katello_installed_packages, :evr

      disable_extension "evr"
    end
  end
end
