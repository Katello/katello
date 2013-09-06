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

class ProviderAuthorizationAdminTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('admin'))
    @provider = Provider.find(providers('fedora_hosted'))
    @org = @acme_corporation
  end

  def test_readable
    refute_empty Provider.readable(@org)
  end

  def test_editable
    refute_empty Provider.editable(@org)
  end

  def test_creatable?
    assert Provider.creatable?(@org)
  end

  def test_any_readable?
    assert Provider.any_readable?(@org)
  end

  def test_readable?
    assert @provider.readable?
  end

  def test_editable?
    assert @provider.editable?
  end

  def test_deletable?
    assert @provider.deletable?
  end

end

class ProviderAuthorizationNoPermsTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('no_perms_user'))
    @provider = Provider.find(providers('fedora_hosted'))
    @org = @acme_corporation
  end

  def test_readable
    assert_empty Provider.readable(@org)
  end

  def test_editable
    assert_empty Provider.editable(@org)
  end

  def test_creatable?
    refute Provider.creatable?(@org)
  end

  def test_any_readable?
    refute Provider.any_readable?(@org)
  end

  def test_readable?
    refute @provider.readable?
  end

  def test_editable?
    refute @provider.editable?
  end

  def test_deletable?
    refute @provider.deletable?
  end

end
