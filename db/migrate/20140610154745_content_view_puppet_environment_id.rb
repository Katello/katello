class ContentViewPuppetEnvironmentId < ActiveRecord::Migration[4.2]
  def up
    add_column :katello_content_view_puppet_environments, :puppet_environment_id, :integer, :null => true
  end

  def down
    remove_column :katello_content_view_puppet_environments, :puppet_environment_id
  end
end
