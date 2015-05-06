module Katello
  module AuthorizationSupportMethods
    # permissions => Array of hashes in the following format
    #   [{:name => :view_lifecycle_environment, :search => 'name=Dev'}, ..]
    def create_role_with_permissions(permissions)
      role = FactoryGirl.create(:role)
      permissions.each do |perm|
        begin
          role.add_permissions!([perm[:name]], :search => perm[:search])
        rescue ArgumentError => e
          raise("Permissions not found: #{perm[:name]}, #{e.message}")
        end
      end
      role
    end

    # permissions => can be a permission(s) in one of the following formats
    # {:name => :view_lifecycle_environments, :search => 'name=Dev'} OR
    # [{:name => :view_lifecycle_environments, :search => 'name=Dev'}, ..] OR
    # :view_lifecycle_environments
    def setup_user_with_permissions(permissions, user)
      actual_permissions =  if permissions.is_a?(Hash)
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
      user.roles = [role]
      user
    end

    def setup_current_user_with_permissions(permissions)
      fail("setup_current_user_with_permissions called with current user not set") unless User.current
      setup_user_with_permissions(permissions, User.current)
    end
  end
end
