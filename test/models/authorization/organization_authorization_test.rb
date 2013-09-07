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

class OrganizationAuthorizationAdminTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('admin'))
    @org = @acme_corporation
  end

  def test_class_readable
    refute_empty Organization.readable
  end

  def def_class_creatable?
    assert Organization.creatable?
  end

  def test_any_readable?
    assert Organization.any_readable?
  end

  def test_editable?
    assert @org.editable?
  end

  def test_deletable?
    assert @org.deletable?
  end

  def test_readable?
    assert @org.readable?
  end

  def test_environments_manageable?
    assert @org.environments_manageable?
  end

  def test_systems_readable?
    assert @org.systems_readable?
  end

  def test_systems_deletable?
    assert @org.systems_deletable?
  end

  def test_systems_registerable?
    assert @org.systems_registerable?
  end

  def test_any_systems_registerable?
    assert @org.systems_registerable?
  end

  def test_gpg_keys_manageable?
    assert @org.gpg_keys_manageable?
  end

  def test_syncable?
    assert @org.syncable?
  end

end

class OrganizationAuthorizationNoPermsTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('no_perms_user'))
    @org = @acme_corporation
  end

  def test_class_readable
    assert_empty Organization.readable
  end

  def def_class_creatable?
    refute Organization.creatable?
  end

  def test_any_readable?
    refute Organization.any_readable?
  end

  def test_editable?
    refute @org.editable?
  end

  def test_deletable?
    refute @org.deletable?
  end

  def test_readable?
    refute @org.readable?
  end

  def test_environments_manageable?
    refute @org.environments_manageable?
  end

  def test_systems_readable?
    refute @org.systems_readable?
  end

  def test_systems_deletable?
    refute @org.systems_deletable?
  end

  def test_systems_registerable?
    refute @org.systems_registerable?
  end

  def test_any_systems_registerable?
    refute @org.systems_registerable?
  end

  def test_gpg_keys_manageable?
    refute @org.gpg_keys_manageable?
  end

  def test_syncable?
    refute @org.syncable?
  end

end
