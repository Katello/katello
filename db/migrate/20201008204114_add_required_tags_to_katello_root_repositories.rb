class AddRequiredTagsToKatelloRootRepositories < ActiveRecord::Migration[6.0]
  def change
    add_column :katello_root_repositories, :required_tags, :text
  end
end
