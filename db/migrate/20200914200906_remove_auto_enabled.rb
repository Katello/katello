class RemoveAutoEnabled < ActiveRecord::Migration[6.0]
  def change
    remove_column :katello_root_repositories, :auto_enabled
  end
end
