#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

class HostsControllerTest < ActionController::TestCase
  def permissions
    @sync_permission = :sync_products
  end

  def models
    @library = katello_environments(:library)
    @library_dev_staging_view = katello_content_views(:library_dev_staging_view)
  end

  def setup
    setup_controller_defaults(false, false)
    login_user(User.find(users(:admin)))
    models
    permissions
  end

  def test_puppet_environment_for_content_view
    get :puppet_environment_for_content_view, :content_view_id => @library_dev_staging_view.id, :lifecycle_environment_id => @library.id

    assert_response :success
  end
end
