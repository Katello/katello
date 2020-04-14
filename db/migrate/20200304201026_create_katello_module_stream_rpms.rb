class CreateKatelloModuleStreamRpms < ActiveRecord::Migration[5.2]
  def change
    create_table :katello_module_stream_rpms do |t|
      t.references :module_stream, :null => false, index: { :name => 'katello_msrpm_module_stream_idx' }
      t.references :rpm, null: false, index: { :name => 'katello_msrpm_rpm_idx' }
      t.timestamps
    end

    add_index :katello_module_stream_rpms, [:module_stream_id, :rpm_id],
              unique: true, name: :katello_msrpm_module_stream_rpms_uniq

    add_foreign_key "katello_module_stream_rpms", "katello_module_streams", :column => "module_stream_id", name: :katello_msrpm_mod_stream_id_fk
    add_foreign_key "katello_module_stream_rpms", "katello_rpms", :column => "rpm_id", name: :katello_msrpm_rpm_id_fk
  end
end
