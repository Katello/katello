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


module ControllerSupport
  def check_permission(params)
    user = params[:user] || no_permission_user

    params[:permission].call(::AuthorizationSupportMethods::UserPermissionsGenerator.new(user))

    action = params[:action]
    req = params[:request]
    @controller.define_singleton_method(action) {render :nothing => true}

    login_user(user)
    req.call

    if params[:authorized]
      assert_response :success
    else
      assert_equal 403, response.status
    end
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
    begin
      user = User.find(users(:no_perms_user))
      user.own_role.permissions.delete_all
      user
    rescue
      # fixtures not loaded
      FactoryGirl.create(:user)
    end
  end
end
