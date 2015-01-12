class AddOrganizationFields < ActiveRecord::Migration
  def change
    add_column :taxonomies, :description, :text unless column_exists?(:taxonomies, :description)
    add_column :taxonomies, :label, :string
    add_column :taxonomies, :deletion_task_id, :integer
    add_column :taxonomies, :default_info, :text
    add_column :taxonomies, :apply_info_task_id, :integer
    add_column :taxonomies, :owner_auto_attach_all_systems_task_id, :integer

    add_index :taxonomies, [:deletion_task_id], :name => "index_organizations_on_task_id"
    add_index :taxonomies, [:label], :name => "index_organizations_on_cp_key", :unique => true
  end
end
