class AddEnvironmentDefaultIdToContentView < ActiveRecord::Migration
  def self.up
    add_column :content_views, :environment_default_id, :integer
    KTEnvironment.all.each do |env|
      cv = ContentView.find(env.default_content_view_id)
      cv.environment_default_id = env.id
      cv.save!
    end
    raise "All environments not properly migrated" if KTEnvironment.count != ContentView.where("environment_default_id is not null").count

    remove_column :environments, :default_content_view_id
    add_index :content_views, [:environment_default_id]
  end

  def self.down
    add_column :environments, :default_content_view_id, :integer
    ContentView.all.each do |cv|
      if cv.environment_default_id
        env = KTEnvironment.find(cv.environment_default_id)
        env.default_content_view_id = cv.id
        env.save!
      end
    end
    remove_column :content_views, :environment_default_id, :integer
    remove_index :content_views, [:environment_default_id]
  end
end
