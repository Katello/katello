class PopulateContentViewEnvironments < ActiveRecord::Migration
  def self.up
    # For each of the environments, a content view environment needs to be
    # created and associated with the environment's default content view
    User.current = User.hidden.first
    KTEnvironment.all.each do |env|
      unless env.content_view_environment
        ContentViewEnvironment.create!(:name => env.name,
                                       :label => env.default_content_view.cp_environment_label(env),
                                       :content_view => env.default_content_view,
                                       :cp_id => env.default_content_view.cp_environment_id(env))
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
