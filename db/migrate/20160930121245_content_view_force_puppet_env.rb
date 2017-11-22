class ContentViewForcePuppetEnv < ActiveRecord::Migration[4.2]
  def change
    add_column :katello_content_views, :force_puppet_environment, :boolean, :default => false
  end
end
