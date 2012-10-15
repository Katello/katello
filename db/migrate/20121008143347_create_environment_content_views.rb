class CreateEnvironmentContentViews < ActiveRecord::Migration
  def self.up
    create_table :environment_content_views do |t|
      t.references :environment
      t.references :content_view

      t.timestamps
    end
    add_index :environment_content_views, [:environment_id, :content_view_id],
      :name => "env_cv_index"
  end

  def self.down
    drop_table :environment_content_views
  end
end
