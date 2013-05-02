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


class GpgKeyAuthorizationAdminTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('admin'))
    @key = GpgKey.find(gpg_keys('fedora_gpg_key'))
  end

  def test_readable
    refute_empty GpgKey.readable(@acme_corporation)
  end

  def test_manageable
    refute_empty GpgKey.manageable(@acme_corporation)
  end

  def test_createable?
    assert GpgKey.createable?(@acme_corporation)
  end

  def test_any_readable?
    assert GpgKey.any_readable?(@acme_corporation)
  end

  def test_key_readable
    assert @key.readable?
  end

  def test_key_manageable?
     assert @key.manageable?
  end
end


class GpgKeyAuthorizationNoPermsTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('no_perms_user'))
    @key = GpgKey.find(gpg_keys('fedora_gpg_key'))
  end

  def test_readable
    assert_empty GpgKey.readable(@acme_corporation)
  end

  def test_manageable
    assert_empty GpgKey.manageable(@acme_corporation)
  end

  def test_createable?
    refute GpgKey.createable?(@acme_corporation)
  end

  def test_any_readable?
    refute GpgKey.any_readable?(@acme_corporation)
  end

  def test_key_readable
    refute @key.readable?
  end

  def test_key_manageable?
     refute @key.manageable?
  end

end
