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


class EnvironmentAuthorizationAdminTest < MiniTest::Rails::ActiveSupport::TestCase
  include RepositoryTestBase

  def setup
    super
    User.current = User.find(users('admin'))
    @env = @dev
    @org = @acme_corporation
  end

  def test_changesets_readable
    assert !KTEnvironment.changesets_readable(@org).empty?
  end

  def test_content_readable
    assert !KTEnvironment.content_readable(@org).empty?
  end

  def test_systems_readable
    assert !KTEnvironment.systems_readable(@org).empty?
  end

  def test_systems_registerable
    assert !KTEnvironment.systems_registerable(@org).empty?
  end

  def test_any_viewable_for_promotions?
    assert KTEnvironment.any_viewable_for_promotions?(@org)
  end

  def test_any_contents_readable?
    assert KTEnvironment.any_contents_readable?(@org)
  end

  #instance tests
  def test_viewable_for_promotions?
    assert @env.viewable_for_promotions?
  end

  def test_any_operation_readable?
    assert @env.any_operation_readable?
  end

  def test_changesets_promotable?
    assert @env.changesets_promotable?
  end

  def test_changesets_deletable?
    assert @env.changesets_deletable?
  end

  def test_changesets_readable?
    assert @env.changesets_readable?
  end

  def test_changesets_manageable?
    assert @env.changesets_manageable?
  end

  def test_contents_readable?
    assert @env.contents_readable?
  end

  def test_systems_readable?
    assert @env.systems_readable?
  end

  def test_systems_editable?
    assert @env.systems_editable?
  end

  def test_systems_deletable?
    assert @env.systems_deletable?
  end

  def test_systems_registerable?
    assert @env.systems_registerable?
  end
end


class EnvironmentAuthorizationNoPermsTest < MiniTest::Rails::ActiveSupport::TestCase
  include RepositoryTestBase


  def setup
    super
    User.current = User.find(users('no_perms_user'))
    @env = @dev
    @org = @acme_corporation
  end

  def test_changesets_readable
    assert KTEnvironment.changesets_readable(@org).empty?
  end

  def test_content_readable
    assert KTEnvironment.content_readable(@org).empty?
  end

  def test_systems_readable
    assert KTEnvironment.systems_readable(@org).empty?
  end

  def test_systems_registerable
    assert KTEnvironment.systems_registerable(@org).empty?
  end

  def test_any_viewable_for_promotions?
    assert !KTEnvironment.any_viewable_for_promotions?(@org)
  end

  def test_any_contents_readable?
    assert !KTEnvironment.any_contents_readable?(@org)
  end

  #instance tests
  def test_viewable_for_promotions?
    assert !@env.viewable_for_promotions?
  end

  def test_any_operation_readable?
    assert !@env.any_operation_readable?
  end

  def test_changesets_promotable?
    assert !@env.changesets_promotable?
  end

  def test_changesets_deletable?
    assert !@env.changesets_deletable?
  end

  def test_changesets_readable?
    assert !@env.changesets_readable?
  end

  def test_changesets_manageable?
    assert !@env.changesets_manageable?
  end

  def test_contents_readable?
    assert !@env.contents_readable?
  end

  def test_systems_readable?
    assert !@env.systems_readable?
  end

  def test_systems_editable?
    assert !@env.systems_editable?
  end

  def test_systems_deletable?
    assert !@env.systems_deletable?
  end

  def test_systems_registerable?
    assert !@env.systems_registerable?
  end

end
