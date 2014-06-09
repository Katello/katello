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

require 'models/authorization/authorization_base'

module Katello
class ContentViewEnvironmentAuthorizationAdminTest < AuthorizationTestBase
  def setup
    super
    User.current = User.find(users(:admin))
    @content_view_environment = katello_content_view_environments(:library_default_view_environment)
  end

  def test_readable?
    assert @content_view_environment.readable?
  end
end

class ContentViewEnvironmentAuthorizationNonAuthUserTest < AuthorizationTestBase
  def setup
    super
    User.current = User.find(users(:restricted))
    @content_view_environment = katello_content_view_environments(:library_default_view_environment)
  end

  def test_readable?
    refute @content_view_environment.readable?
  end
end

class ContentViewEnvironmentAuthorizationAuthorizedUserTest < AuthorizationTestBase
  def setup
    super
    User.current = User.find(users(:restricted))
    @content_view_environment = katello_content_view_environments(:library_default_view_environment)
  end

  def test_readable?
    setup_current_user_with_permissions([:view_content_views, :view_lifecycle_environments])
    assert @content_view_environment.readable?
  end
end
end
