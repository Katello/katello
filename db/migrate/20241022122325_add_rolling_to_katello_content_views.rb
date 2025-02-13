class AddRollingToKatelloContentViews < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_content_views, :rolling, :boolean, :default => false
  end
end
