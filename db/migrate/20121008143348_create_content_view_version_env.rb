class CreateContentViewVersionEnv < ActiveRecord::Migration
  def self.up
    create_table :content_view_version_environments, :id=>false do |t|
      t.references :content_view_version
      t.references :environment
      t.timestamps
    end
    add_index :content_view_version_environments, [:content_view_version_id, :environment_id],
      :name => "cvv_env_index"
  end

  def self.down
    drop_table :content_view_version_environments
  end
end
