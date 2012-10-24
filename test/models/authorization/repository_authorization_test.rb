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

require 'test/models/repository_base'


class RepositoryAuthorizationAdminTest < MiniTest::Rails::ActiveSupport::TestCase
  include RepositoryTestBase

  def setup
    super
    User.current = User.find(users(:admin))
  end

  def test_readable
    assert !Repository.readable(@library).empty?
  end

  def test_libraries_content_readable
    assert !Repository.libraries_content_readable(@acme_corporation).empty?
  end

  def test_content_readable
    assert !Repository.content_readable(@acme_corporation).empty?
  end

  def test_readable_for_product
    assert !Repository.readable_for_product(@library, @fedora).empty?
  end

  def test_editable_in_library
    assert !Repository.editable_in_library(@acme_corporation).empty?
  end

  def test_readable_in_org
    assert !Repository.readable_in_org(@acme_corporation).empty?
  end

  def test_any_readable_in_org?
    assert Repository.any_readable_in_org?(@acme_corporation)
  end

end


class RepositoryAuthorizationNonAuthUserTest < MiniTest::Rails::ActiveSupport::TestCase
  include RepositoryTestBase

  def setup
    super
    User.current = User.find(users(:no_perms_user))
  end

  def test_readable
    assert Repository.readable(@library).empty?
  end

  def test_libraries_content_readable
    assert Repository.libraries_content_readable(@acme_corporation).empty?
  end

  def test_content_readable
    assert Repository.content_readable(@acme_corporation).empty?
  end

  def test_readable_for_product
    assert Repository.readable_for_product(@library, @fedora).empty?
  end

  def test_editable_in_library
    assert Repository.editable_in_library(@acme_corporation).empty?
  end

  def test_readable_in_org
    assert Repository.readable_in_org(@acme_corporation).empty?
  end

  def test_any_readable_in_org?
    assert !Repository.any_readable_in_org?(@acme_corporation)
  end

end
