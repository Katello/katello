class RemoveDeletionTaskIdFromTaxonomies < ActiveRecord::Migration
  def up
    remove_column :taxonomies, :deletion_task_id
  end

  def down
    add_column :taxonomies, :deletion_task_id, :integer
  end
end
