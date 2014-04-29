#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'models/authorization/authorization_base'

module Katello
class ActivationKeyAuthorizationAdminTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users('admin'))
    @key = ActivationKey.find(katello_activation_keys('simple_key'))
  end

  def test_readable
    refute_empty ActivationKey.readable
  end

  def test_readable?
    assert @key.readable?
  end

  def test_editable?
    assert @key.editable?
  end

  def test_deletable?
    assert @key.deletable?
  end

end

class ActivationKeyAuthorizationNoPermsTest  < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users(:restricted))
    @key = ActivationKey.find(katello_activation_keys('simple_key'))
  end

  def test_readable?
    refute @key.readable?
  end

  def test_editable?
    refute @key.editable?
  end

  def test_deletable?
    refute @key.deletable?
  end

end
end
