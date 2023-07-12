class RemoveRelativePathLimit < ActiveRecord::Migration[6.1]
  def change
    change_column :katello_repositories, :relative_path, :text
  end
end
