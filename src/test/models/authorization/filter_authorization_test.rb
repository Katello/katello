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

require './test/models/authorization/authorization_base'


class FilterAuthorizationAdminTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('admin'))
    @filter = Filter.find(filters('fedora_filter'))
  end

  def test_creatable?
    assert Filter.creatable?(@acme_corporation)
  end

  def test_any_editable?
    assert Filter.any_editable?(@acme_corporation)
  end

  def test_any_readable?
    assert Filter.any_editable?(@acme_corporation)
  end

  def test_readable?
    assert @filter.readable?
  end

  def test_editable?
    assert @filter.editable?
  end

  def test_deletable?
    assert @filter.deletable?
  end
end


class FilterAuthorizationNoPermsTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('no_perms_user'))
    @filter = Filter.find(filters('fedora_filter'))
  end

  def test_creatable?
    refute Filter.creatable?(@acme_corporation)
  end

  def test_any_editable?
    refute Filter.any_editable?(@acme_corporation)
  end

  def test_any_readable?
    refute Filter.any_editable?(@acme_corporation)
  end

  def test_readable?
    refute @filter.readable?
  end

  def test_editable?
    refute @filter.editable?
  end

  def test_deletable?
    refute @filter.deletable?
  end

end
