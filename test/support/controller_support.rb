#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require "#{Katello::Engine.root}/test/support/auth_support"

module ControllerSupport
  include Katello::AuthorizationSupportMethods

  def check_permission(params)
    permissions = params[:permission].is_a?(Array) ? params[:permission] : [params[:permission]]

    permissions.each do |permission|
      # TODO: allow user to be passed in via params and clear permissions between iterations
      user = no_permission_user

      if permission
        permission.call(Katello::AuthorizationSupportMethods::UserPermissionsGenerator.new(user))
      end

      action = params[:action]
      req = params[:request]
      @controller.define_singleton_method(action) {render :nothing => true}

      login_user(user)
      req.call

      if params[:authorized]
        msg = "Expected response for #{action} to be a <success>, but was <#{response.status}> instead. \n" +
          "#{user.own_role.summary}"
        assert_response :success, msg
      else
        msg = "Security Violation (403) expected for #{action}, got #{response.status} instead. \n#{user.own_role.summary}"
        assert_equal 403, response.status, msg
      end
    end
  end

  def assert_protected_action(action_name, allowed_perms, denied_perms, &block)
    assert_authorized(
        :permission => allowed_perms,
        :action => action_name,
        :request => block
    )
    refute_authorized(
        :permission => denied_perms,
        :action => action_name,
        :request => block
    )
  end

  def assert_authorized(params)
    check_params = params.merge(authorized: true)
    check_permission(check_params)
  end

  def refute_authorized(params)
    check_params = params.merge(authorized: false)
    check_permission(check_params)
  end

  def no_permission_user
    user = User.find(users(:restricted))
    user.own_role.permissions.delete_all
    user
  end
end

UserPermission = Struct.new(:verbs, :resource_type, :tags, :org, :options) do
  def call(generator)
    self.tags ||= []
    self.options ||= {}
    generator.can(verbs, resource_type, tags, org, options)
  end

  def +(permission)
    UserPermissionSet.new([self, permission])
  end
end

# create a constant for a lack of permissions
NO_PERMISSION = lambda { |user| }

class UserPermissionSet
  attr_accessor :permissions

  def initialize(permissions = [])
    self.permissions = permissions
  end

  def +(user_permission)
    self.permissions << user_permission
  end
  alias_method :<<, :+

  def call(generator)
    permissions.each { |p| p.call(generator) }
  end
end
