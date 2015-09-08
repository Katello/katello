class RemoveApplyInfoTaskIdFromTaxonomies < ActiveRecord::Migration
  def change
    remove_column :taxonomies, :apply_info_task_id
  end
end
