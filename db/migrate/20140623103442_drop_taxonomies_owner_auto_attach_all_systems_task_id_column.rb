class DropTaxonomiesOwnerAutoAttachAllSystemsTaskIdColumn < ActiveRecord::Migration
  def up
    remove_column :taxonomies, :owner_auto_attach_all_systems_task_id
  end

  def down
    add_column :taxonomies, :owner_auto_attach_all_systems_task_id, :integer
  end
end
