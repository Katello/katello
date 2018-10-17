class AddModulesToErrataPackages < ActiveRecord::Migration[5.2]
  def up
    create_table :katello_module_stream_erratum_packages do |t|
      t.references :module_stream, null: false, index: { name: :katello_msep_stream_idx }
      t.references :erratum_package, null: false, index: { name: :katello_msep_erratum_package_idx }
      t.timestamps
    end
    add_index :katello_module_stream_erratum_packages, [:module_stream_id, :erratum_package_id],
              unique: true, name: :katello_module_stream_erratum_package_uniq

    add_foreign_key :katello_module_stream_erratum_packages,
                    :katello_module_streams,
                    column: :module_stream_id,
                    name: :katello_msep_mod_stream_id_fk

    add_foreign_key :katello_module_stream_erratum_packages,
                    :katello_erratum_packages,
                    column: :erratum_package_id,
                    name: :katello_msep_erratum_package_id_fk
    change_column :katello_module_stream_erratum_packages, :created_at, :datetime, :null => true
    change_column :katello_module_stream_erratum_packages, :updated_at, :datetime, :null => true
  end

  def down
    remove_foreign_key :katello_module_stream_erratum_packages, name: :katello_msep_mod_stream_id_fk
    remove_foreign_key :katello_module_stream_erratum_packages, name: :katello_msep_erratum_package_id_fk
    drop_table :katello_module_stream_erratum_packages
  end
end
