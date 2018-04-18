class AddIgnorableContentToRepository < ActiveRecord::Migration[5.1]
  def change
    add_column :katello_repositories, :ignorable_content, :text, :null => true
  end
end
