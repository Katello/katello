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

require './test/models/authorization/authorization_base'

class RoleAuthorizationAdminTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('admin'))
    @role = Role.find(roles(:administrator))
  end

  def test_readable
    refute_empty Role.readable
  end

  def test_creatable?
    assert Role.creatable?
  end

  def test_editable?
    assert Role.editable?
  end

  def test_deletable?
    assert Role.deletable?
  end

  def test_any_readable?
    assert Role.any_readable?
  end

  def test_readable?
    assert Role.readable?
  end

end

class RoleAuthorizationNoPermsTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('no_perms_user'))
    @role = Role.find(roles(:administrator))
  end

  def test_readable
    assert Role.readable.empty?
  end

  def test_creatable?
    refute Role.creatable?
  end

  def test_editable?
    refute Role.editable?
  end

  def test_deletable?
    refute Role.deletable?
  end

  def test_any_readable?
    refute Role.any_readable?
  end

  def test_readable?
    refute Role.readable?
  end

end
