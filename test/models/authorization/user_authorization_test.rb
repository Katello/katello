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
require 'support/auth_support'

module Katello
class UserAuthorizationAdminTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('admin'))
    @user = User.find(users('restricted'))
  end

  def test_creatable?
    assert User.creatable?
  end

  def test_any_readable?
    assert User.any_readable?
  end

  def test_readable?
    assert @user.readable?
  end

  def test_editable?
    assert @user.editable?
  end

  def test_deletable?
    assert @user.deletable?
  end

  def test_admin_deletable?
    refute User.current.deletable?
  end

  def test_readable
    assert_includes User.readable, @user
  end

end

class UserAuthorizationNoPermsTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('restricted'))
    @user = User.current
  end

  def test_creatable?
    refute User.creatable?
  end

  def test_any_readable?
    refute User.any_readable?
  end

  def test_readable?
    refute @user.readable?
  end

  def test_editable?
    refute @user.editable?
  end

  def test_deletable?
    refute @user.deletable?
  end

end

class UserOrganizationAccess < AuthorizationTestBase
  include AuthorizationSupportMethods

  def setup
    super
    @user = @no_perms_user
    @org = @acme_corporation
    @org2 = get_organization(:organization2)
  end

  def test_access_two_orgs
    assert_equal 0, @user.allowed_organizations.size

    allow(@user.own_role, [:read], :roles, nil, @org)
    allow(@user.own_role,[:read], :roles, nil, @org2)

    assert_equal 2, @user.allowed_organizations.size
  end
end
end
