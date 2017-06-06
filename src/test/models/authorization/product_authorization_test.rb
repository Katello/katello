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


class ProductAuthorizationAdminTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('admin'))
    @prod = @fedora
    @org = @acme_corporation
  end

  def test_all_readable
    refute_empty Product.all_readable(@org)
  end

  def test_readable
    refute_empty Product.readable(@org)
  end

  def test_all_editable
    refute_empty Product.all_editable(@org)
  end

  def test_editable
    refute_empty Product.editable(@org)
  end

  def test_syncable
    refute_empty Product.syncable(@org)
  end

  def test_any_readable?
    assert Product.any_readable?(@org)
  end

  def test_readable?
    assert @prod.readable?
  end

  def test_syncable?
    assert @prod.syncable?
  end

  def test_editable?
    assert @prod.editable?
  end

end


class ProductAuthorizationNoPermsTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('no_perms_user'))
    @prod = @fedora
    @org = @acme_corporation

  end

  def test_all_readable
    assert_empty Product.all_readable(@org)
  end

  def test_readable
    assert_empty Product.readable(@org)
  end

  def test_all_editable
    assert_empty Product.all_editable(@org)
  end

  def test_editable
    assert_empty Product.editable(@org)
  end

  def test_syncable
    assert_empty Product.syncable(@org)
  end

  def test_any_readable?
    refute Product.any_readable?(@org)
  end

  def test_readable?
    refute @prod.readable?
  end

  def test_syncable?
    refute @prod.syncable?
  end

  def test_editable?
    refute @prod.editable?
  end

end
