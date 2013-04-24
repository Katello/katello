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
  def assert_permission(params)
    authorized = User.find(users(:authorized))
    unauthorized = User.find(users(:unauthorized))

    params[:authorized].call(
        ::AuthorizationSupportMethods::UserPermissionsGenerator.new(authorized)) if params.has_key?(:authorized)

    params[:unauthorized].call(
        ::AuthorizationSupportMethods::UserPermissionsGenerator.new(unauthorized)) if params.has_key?(:unauthorized)

    action = params[:action]
    req = params[:request]
    @controller.define_singleton_method(action) {render :nothing => true}

    login_user(authorized)
    req.call
    assert_response :success

    login_user(unauthorized)
    req.call
    assert_equal 403, response.status
  end
end
