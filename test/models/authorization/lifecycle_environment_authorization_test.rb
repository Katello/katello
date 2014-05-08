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
class EnvironmentAuthorizationAdminTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('admin'))
    @env = @dev
    @org = @acme_corporation
  end

  def test_readable
    refute_empty KTEnvironment.readable
  end

  def test_promotable?
    assert @env.promotable_or_removable?
  end

  def test_promotable
    refute_empty KTEnvironment.promotable
  end

  def test_any_promotable?
    assert KTEnvironment.any_promotable?
  end
end

class EnvironmentAuthorizationNoPermsTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('restricted'))
    @env = @dev
    @org = @acme_corporation
  end

  def test_readable
    assert_empty KTEnvironment.readable
  end

  def test_promotable?
    refute @env.promotable_or_removable?
  end

  def test_promotable
    assert_empty KTEnvironment.promotable
  end

  def test_any_promotable?
    refute KTEnvironment.any_promotable?
  end
end

class EnvironmentAuthorizationWithPermsTest < AuthorizationTestBase
  def setup
    super
    User.current = User.find(users('restricted'))
  end

  def test_readables
    environment = katello_environments(:staging_path1)
    setup_current_user_with_permissions(:name => "view_lifecycle_environments",
                                        :search => "name=\"#{environment.name}\"")
    assert_equal([environment.id], KTEnvironment.readable.pluck(:id))
    assert environment.readable?
    refute environment.prior.readable?
  end

  def test_promotables
    environment = katello_environments(:staging_path1)
    setup_current_user_with_permissions(:name => "promote_or_remove_content_views_to_environments",
                                        :search => "name=\"#{environment.name}\"")
    assert_equal([environment.id], KTEnvironment.promotable.pluck(:id))
    assert environment.promotable_or_removable?
    refute environment.prior.promotable_or_removable?
  end
end
end
