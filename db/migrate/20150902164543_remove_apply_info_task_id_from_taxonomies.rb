class RemoveApplyInfoTaskIdFromTaxonomies < ActiveRecord::Migration[4.2]
  def change
    remove_column :taxonomies, :apply_info_task_id
  end
end
