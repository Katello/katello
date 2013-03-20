class MigrateEnvironmentViewsToOrganization < ActiveRecord::Migration
  def self.up
    #before this migration is run, environments have their own content views
    # for default content
    #Here we move those cv versions to the org default CV
    #  and delete the environment default content views (which should be empty)
    User.current = User.hidden.first
    Organization.all.each do |org|
      def_view = org.default_content_view
      def_view.name = "Default Organization View"
      (org.environments + [org.library]).each do |env|
        cv_env = env.content_view_environment
        old_view = env.default_content_view
        version = env.default_content_view_version

        version.content_view = def_view
        version.save!
        cv_env.content_view = def_view
        cv_env.save!
        old_view.destroy
      end
      def_view.save!
    end
  end

  def self.down
    Organization.all.each do |org|
      view = org.default_content_view
      (org.environments + [org.library]).each do |env|
        cve = view.content_view_environments.where(:environment_id=>env.id).first
        cv = ContentView.new(:organization=>org, :name=>"Default View for #{env.name}",
                           :default=>true)
        cv.content_view_environments << cve
        cv.save!
        cve.content_view_id = cv.id
        cve.save!
        version = env.default_content_view_version
        version.content_view = cv
        version.save!
      end
    end
  end
end
