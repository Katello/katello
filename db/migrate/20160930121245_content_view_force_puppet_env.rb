class ContentViewForcePuppetEnv < ActiveRecord::Migration
  def change
    add_column :katello_content_views, :force_puppet_environment, :boolean, :default => false
  end
end
