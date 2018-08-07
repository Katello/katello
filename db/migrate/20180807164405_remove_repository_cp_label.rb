class RemoveRepositoryCpLabel < ActiveRecord::Migration[5.1]
  def change
    remove_column :katello_repositories, :cp_label
  end
end
