class PopulateContentViewEnvironments < ActiveRecord::Migration
  def self.up
    # For each katello environment, associate it with the environment's
    # default content view version.  This will trigger the creation of
    # the content view environment.
    User.current = User.hidden.first
   ActiveRecord::Base.connection.raw_connection.prepare('insert_cvve', "insert into content_view_version_environments (content_view_version_id, environment_id, created_at, updated_at) values ($1, $2, $3, $4)")
    KTEnvironment.all.each do |env|
      unless env.content_view_environment
        # a kt_environment will only have a single version
        view = ContentView.find(env.default_content_view_id)
        version = view.versions.first

       ActiveRecord::Base.connection.raw_connection.exec_prepared('insert_cvve', [version.id, env.id, DateTime.now, DateTime.now])

        ContentViewEnvironment.create!(:content_view=>view,
                                       :name => env.name,
                                       :label => view.send(:generate_cp_environment_label, env),
                                       :cp_id => view.send(:generate_cp_environment_id, env))

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
