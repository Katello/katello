class RemoveDefaultAndCustomInfo < ActiveRecord::Migration
  def change
    remove_column :taxonomies, :default_info
  end
end
