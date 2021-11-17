module Katello
  module AuthorizationSupportMethods
    # permissions => Array of hashes in the following format
    #   [{:name => :view_lifecycle_environment, :search => 'name=Dev', :resource_type => 'Katello::KTEnvironment'}, ..]
    def create_role_with_permissions(permissions)
      role = FactoryBot.create(:role)
      permissions.each do |perm|
        ensure_permission_exist(perm)
        begin
          role.add_permissions!([perm[:name]], :search => perm[:search])
        rescue ArgumentError => e
          Rails.logger.error("Permission query: #{Permission.where(:name => [perm[:name]]).all}")
          Rails.logger.error("Permission list: #{Permission.pluck(:name)}")
          raise("Permissions not found: #{perm[:name]}, #{e.message}:  #{Permission.pluck(:name)}")
        end
      end
      role
    end

    def ensure_permission_exist(hash)
      perm = Permission.find_by :name => hash[:name]
      return if perm
      resource_type = hash.key?(:resource_type) ? hash[:resource_type] : resource_type_from_name(hash[:name])
      FactoryBot.create(:permission, :name => hash[:name], :resource_type => resource_type)
    end

    def resource_type_from_name(name)
      resource_name = name.to_s.split('_')[1..-1].join('_').singularize
      mapping = {
        "capsule_content" => "SmartProxy",
        "manifest" => "Katello::Subscription",
        "lifecycle_environment" => "Katello::KTEnvironment",
        "or_remove_content_views_to_environment" => "Katello::KTEnvironment",
        "or_remove_content_view" => "Katello::ContentView"
      }
      mapping[resource_name] || verify_resource(resource_name.camelize)
    end

    def verify_resource(name_from_permission)
      return name_from_permission.camelize.constantize.to_s rescue nil
      return "Katello::#{name_from_permission.camelize}".constantize.to_s rescue nil
      fail "Cannot infer resource_type from permission name. If resource_type is meant to be nil, please state it explicitely in your test."
    end

    # permissions => can be a permission(s) in one of the following formats
    # {:name => :view_lifecycle_environments, :search => 'name=Dev'} OR
    # [{:name => :view_lifecycle_environments, :search => 'name=Dev'}, ..] OR
    # :view_lifecycle_environments
    def setup_user_with_permissions(permissions, user, organizations: [], locations: [])
      as_admin do
        user.update!(organizations: organizations) unless organizations.blank?
        user.update!(locations: locations) unless locations.blank?

        actual_permissions = if permissions.is_a?(Hash)
                               [permissions]
                             elsif permissions.is_a?(Array)
                               permissions.collect do |perm|
                                 if perm.is_a?(Hash)
                                   perm
                                 else
                                   {:name => perm}
                                 end
                               end
                             else
                               [{:name => permissions}]
                             end

        role = create_role_with_permissions(actual_permissions)
        user.update!(roles: [role])
        user
      end
    end

    def setup_current_user_with_permissions(permissions, organizations: [], locations: [])
      fail("setup_current_user_with_permissions called with current user not set") unless User.current
      setup_user_with_permissions(permissions, User.current, organizations: organizations, locations: locations)
    end
  end
end
