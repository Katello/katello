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


class ActivationKeyAuthorizationAdminTest < MiniTest::Rails::ActiveSupport::TestCase
  include RepositoryTestBase

  def setup
    super
    User.current = User.find(users('admin'))
  end

  def test_readable
    assert !ActivationKey.readable(@acme_corporation).empty?
  end

  def test_readable?
    assert ActivationKey.readable?(@acme_corporation)
  end

  def test_manageable?
    assert ActivationKey.manageable?(@acme_corporation)
  end

end


class ActivationKeyAuthorizationNoPermsTest < MiniTest::Rails::ActiveSupport::TestCase
  include RepositoryTestBase
  include ::TestUserBase

  def setup
    super
    User.current = @no_perms_user
  end

  def test_readable
    assert ActivationKey.readable(@acme_corporation).empty?
  end

  def test_readable?
    assert !ActivationKey.readable?(@acme_corporation)
  end

  def test_manageable?
    assert !ActivationKey.manageable?(@acme_corporation)
  end

end
