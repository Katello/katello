class PopulateContentViewEnvironments < ActiveRecord::Migration
  def self.up
    # For each katello environment, associate it with the environment's
    # default content view version.  This will trigger the creation of
    # the content view environment.
    User.current = User.hidden.first
    KTEnvironment.all.each do |env|
      unless env.content_view_environment
        # a kt_environment will only have a single version
        view = ContentView.find(env.default_content_view_id)
        version = view.versions.first

        ActiveRecord::Base.connection.execute("insert into content_view_version_environments (content_view_version_id, environment_id) values (#{version.id}, #{env.id})")
        ContentViewEnvironment.create!(:content_view=>view,
                                     :name => env.name,
                                     :label => view.cp_environment_label(env),
                                     :cp_id => view.cp_environment_id(env))

        # perform a save on each of the environment's repos.
        # this will trigger an update to the search index
        env.repositories.each do |repo|
          repo.save!
        end
      end
    end
  end

  def self.down
    # Purposely not providing a down migration for this one.  If the content
    # view environment table exists, then there really should be these records.
    # So, the assumption is that if the content_view_environment is not desired,
    # the user will continue to rollback schemas until the content view environment
    # schema is removed which will effectively roll this back as well.
  end
end
