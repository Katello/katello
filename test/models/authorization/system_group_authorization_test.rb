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

require 'models/system_base'


class SystemGroupAuthorizationAdminTest < MiniTest::Rails::ActiveSupport::TestCase
  include SystemTestBase

  def setup
    super
    User.current = User.find(users('admin'))
    @group = SystemGroup.find(system_groups(:simple_group))
    @org = @acme_corporation
  end


  def test_readable
     assert !SystemGroup.readable(@org).empty?
   end

  def test_editable
   assert !SystemGroup.editable(@org).empty?
  end

  def test_systems_readable
   assert !SystemGroup.systems_readable(@org).empty?
  end

  def test_systems_editable
   assert !SystemGroup.systems_editable(@org).empty?
  end

  def test_systems_deletable
   assert !SystemGroup.systems_deletable(@org).empty?
  end

  def test_creatable?
  assert SystemGroup.creatable?(@org)
  end

  def test_any_readable?
  assert SystemGroup.any_readable?(@org)
  end


  def test_systems_readable?
    assert @group.systems_readable?
  end

  def test_systems_deletable?
    assert @group.systems_deletable?
  end

  def test_systems_editable?
    assert @group.systems_editable?
  end

  def test_readable?
    assert @group.readable?
  end

  def test_editable?
    assert @group.editable?
  end

  def test_deletable?
    assert @group.deletable?
  end
end


class SystemGroupAuthorizationNoPermsTest < MiniTest::Rails::ActiveSupport::TestCase
  include SystemTestBase

  def setup
    super
    User.current = User.find(users('no_perms_user'))
    @group = SystemGroup.find(system_groups(:simple_group))
    @org = @acme_corporation
  end

  def test_readable
     assert SystemGroup.readable(@org).empty?
   end

  def test_editable
   assert SystemGroup.editable(@org).empty?
  end

  def test_systems_readable
   assert SystemGroup.systems_readable(@org).empty?
  end

  def test_systems_editable
   assert SystemGroup.systems_editable(@org).empty?
  end

  def test_systems_deletable
   assert SystemGroup.systems_deletable(@org).empty?
  end

  def test_creatable?
  assert !SystemGroup.creatable?(@org)
  end

  def test_any_readable?
  assert !SystemGroup.any_readable?(@org)
  end


  def test_systems_readable?
    assert !@group.systems_readable?
  end

  def test_systems_deletable?
    assert !@group.systems_deletable?
  end

  def test_systems_editable?
    assert !@group.systems_editable?
  end

  def test_readable?
    assert !@group.readable?
  end

  def test_editable?
    assert !@group.editable?
  end

  def test_deletable?
    assert !@group.deletable?
  end
end
