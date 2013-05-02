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


class SystemAuthorizationAdminTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('admin'))
    @sys = @system
    @org = @acme_corporation
    @env = @dev
  end

  def test_readable
    refute_empty System.readable(@org)
  end

  def test_registerable?
    assert System.registerable?(@env, @org)
  end

  def test_any_deletable?
    assert System.any_deletable?(@env, @org)
  end

  def test_any_readable?
    assert System.any_readable?(@org)
  end

  def test_readable?
    assert @sys.readable?
  end

  def test_editable?
    assert @sys.editable?
  end

  def test_deletable?
    assert @sys.deletable?
  end

end


class SystemAuthorizationNoPermsTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('no_perms_user'))
    @sys = @system
    @org = @acme_corporation
    @env = @dev
  end

  def test_readable
    assert_empty System.readable(@org)
  end

  def test_registerable?
    refute System.registerable?(@env, @org)
  end

  def test_any_deletable?
    refute System.any_deletable?(@env, @org)
  end

  def test_any_readable?
    refute System.any_readable?(@org)
  end

  def test_readable?
    refute @sys.readable?
  end

  def test_editable?
    refute @sys.editable?
  end

  def test_deletable?
    refute @sys.deletable?
  end

end
