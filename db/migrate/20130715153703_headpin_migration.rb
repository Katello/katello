class HeadpinMigration < ActiveRecord::Migration
  def up
    if Katello.config.headpin?
      # * A system group will be made for each existing env
      # * Systems will be added to appropriate system group
      # * All systems moved to Library env
      User.current = User.hidden.first
      non_library_envs = KTEnvironment.where(:library => false)
      non_library_envs.each do |env|
        # create a system group with the same name as env
        group = SystemGroup.create!(:name => env.name, :description => "Group systems in #{env.name}",
                              :organization => env.organization)
        system_ids = env.system_ids
        system_ids.each do |system_id|
          s = System.find(system_id)
          s.system_groups << group
          s.environment = env.organization.library
          s.content_view = s.environment.default_content_view
          s.save!
        end
      end

      #  All users with a default system registration env will have that changed to Library
      User.all.each do |user|
        if user.default_environment && !user.default_environment.library?
          user.default_environment =  user.default_environment.organization.library
          user.save!
        end
      end

      #  All activation keys will be switched to Library
      ActivationKey.all.each do |ak|
        if ak.environment && !ak.environment.library?
          ak.system_groups << SystemGroup.find_by_name(ak.environment.name)
          ak.environment = ak.environment.organization.library
          ak.content_view = ak.environment.default_content_view
          ak.save!
        end
      end

      # Delete the non library envs
      Organization.all.each do |org|
        org.promotion_paths.each do |path|
          path.reverse.each do |env|
            env.reload.destroy unless env.library?
          end
        end
      end

      # Delete environment permissions
      execute("delete from permission_tags where permission_id in (select id from permissions where resource_type_id=(select id from resource_types where name='environments'))")
      execute("delete from permissions_verbs where permission_id in (select id from permissions where resource_type_id=(select id from resource_types where name='environments'))")
      execute("delete from permissions where resource_type_id=(select id from resource_types where name='environments')")
      execute("delete from resource_types where name='environments'")
    end
  end

  def down
  end
end
