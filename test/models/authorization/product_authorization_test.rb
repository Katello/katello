#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'models/repository_base'


class ProductAuthorizationAdminTest < MiniTest::Rails::ActiveSupport::TestCase
  include RepositoryTestBase

  def setup
    super
    User.current = User.find(users('admin'))
    @prod = @fedora
    @org = @acme_corporation
  end

  def test_all_readable
    assert !Product.all_readable(@org).empty?
  end

  def test_readable
    assert  !Product.readable(@org).empty?
  end

  def test_all_editable
    assert  !Product.all_editable(@org).empty?
  end

  def test_editable
    assert  !Product.editable(@org).empty?
  end

  def test_syncable
    assert  !Product.syncable(@org).empty?
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


class ProductAuthorizationNoPermsTest < MiniTest::Rails::ActiveSupport::TestCase
  include RepositoryTestBase


  def setup
    super
    User.current = User.find(users('no_perms_user'))
    @prod = @fedora
    @org = @acme_corporation

  end

  def test_all_readable
    assert Product.all_readable(@org).empty?
  end

  def test_readable
    assert  Product.readable(@org).empty?
  end

  def test_all_editable
    assert  Product.all_editable(@org).empty?
  end

  def test_editable
    assert  Product.editable(@org).empty?
  end

  def test_syncable
    assert  Product.syncable(@org).empty?
  end

  def test_any_readable?
    assert !Product.any_readable?(@org)
  end

  def test_readable?
    assert !@prod.readable?
  end

  def test_syncable?
    assert !@prod.syncable?
  end

  def test_editable?
    assert !@prod.editable?
  end

end
