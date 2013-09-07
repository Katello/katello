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

module WardenSupport
  DEFAULT_EXPECTED = [:authenticate!]

  def login_user(user=nil, org=nil)
    if user.is_a?(UserPermission) || user.is_a?(UserPermissionSet)
      permissions = user
      user = nil
    end
    user ||= default_user
    yield ::AuthorizationSupportMethods::UserPermissionsGenerator.new(user) if block_given?

    if permissions
      permissions.call(::AuthorizationSupportMethods::UserPermissionsGenerator.new(user))
    end

    request.env['warden'] = Class.new do
      define_method(:user) { user }
      define_method(:authenticate) { user }
      define_method(:authenticate!) { user }
      define_method(:raw_session) { {} }
      define_method(:logout) { true }
    end.new

    ApplicationController.instance_eval do
      define_method(:current_organization) do
        Organization.find(org.id)
      end
    end if org
    #ApplicationHelper.instance_eval do
    #  define_method(:user){user}
    #end
    Api::ApiController.instance_eval do
      define_method(:require_user) { {} }
      define_method(:current_user) { user }
    end
  end

  def with_logged_in_user(user, expected_methods = DEFAULT_EXPECTED)
    warden = Minitest::Mock.new
    warden.expect(:user, user) if expected_methods.include?(:user)
    warden.expect(:authenticate, user) if expected_methods.include?(:authenticate)
    warden.expect(:authenticate!, user) if expected_methods.include?(:authenticate!)
    warden.expect(:raw_session, Object.new) if expected_methods.include?(:raw_session)
    warden.expect(:logout, true) if expected_methods.include?(:logout)

    Api::V1::ApiController.stub(:require_user, {}) do
      Api::V1::ApiController.stub(:current_user, user) do
        yield
      end
    end

    warden.verify
  end

  def disable_user_orchestraction
    disable_glue_layers(["Pulp"], ["User"])
  end

  def default_user
    User.find(users(:no_perms_user))
  rescue
    # fixtures not loaded
    FactoryGirl.create(:user)
  end
end
