class MigrateEnvironmentDefaultContentViewToVersion < ActiveRecord::Migration
  def self.up
    change_column :content_views, :environment_default_id, :integer, :null=>true
    Organization.all.each do |org|
      default_view = ContentView.create!(:name=>"Default Organization View",
                      :organization=>org,
                      :default=>true)
      (org.environments + [org.library]).each do |env|
         old_view = ContentView.where(:environment_default_id=>env.id).first
         cve = old_view.content_view_environments.first
         version = ContentViewVersion.find(old_view.version(env))

         version.content_view = default_view
         version.save!
         cve.content_view = default_view
         cve.save!
         old_view.destroy
      end
      default_view.save!
    end
    remove_column :content_views, :environment_default_id

  end

  def self.down
    add_column :content_views, :environment_default_id, :integer, :null=>true
    Organization.all.each do |org|
      org_default_view = org.default_content_view
      (org.environments + [org.library]).each do |env|
        cv = ContentView.create!(:organization=>org, :name=>"Default View for #{env.name}",
                             :default=>true, :environment_default_id=>env.id)
        cve = org_default_view.content_view_environments.where(:environment_id=>env.id).first

        cve.content_view = cv
        cve.save!

        version = org_default_view.version(env)
        version.content_view = cv
        version.save!
      end
      org_default_view.destroy
    end
  end
end
