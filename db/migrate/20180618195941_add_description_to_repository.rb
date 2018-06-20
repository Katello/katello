class AddDescriptionToRepository < ActiveRecord::Migration[5.1]
  def change
    add_column :katello_repositories, :description, :text, :null => true
  end
end
