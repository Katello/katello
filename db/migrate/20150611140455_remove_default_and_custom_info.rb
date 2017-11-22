class RemoveDefaultAndCustomInfo < ActiveRecord::Migration[4.2]
  def change
    remove_column :taxonomies, :default_info
  end
end
