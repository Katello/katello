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


class RepositoryAuthorizationAdminTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users(:admin))
  end

  def test_readable
    refute_empty Repository.readable(@library)
  end

  def test_libraries_content_readable
    refute_empty Repository.libraries_content_readable(@acme_corporation)
  end

  def test_content_readable
    refute_empty Repository.content_readable(@acme_corporation)
  end

  def test_readable_for_product
    refute_empty Repository.readable_for_product(@library, @fedora)
  end

  def test_editable_in_library
    refute_empty Repository.editable_in_library(@acme_corporation)
  end

  def test_readable_in_org
    refute_empty Repository.readable_in_org(@acme_corporation)
  end

  def test_any_readable_in_org?
    assert Repository.any_readable_in_org?(@acme_corporation)
  end

end


class RepositoryAuthorizationNonAuthUserTest < AuthorizationTestBase

  def setup
    super
    User.current = User.find(users(:no_perms_user))
  end

  def test_readable
    assert_empty Repository.readable(@library)
  end

  def test_libraries_content_readable
    assert_empty Repository.libraries_content_readable(@acme_corporation)
  end

  def test_content_readable
    assert_empty Repository.content_readable(@acme_corporation)
  end

  def test_readable_for_product
    assert_empty Repository.readable_for_product(@library, @fedora)
  end

  def test_editable_in_library
    assert_empty Repository.editable_in_library(@acme_corporation)
  end

  def test_readable_in_org
    assert_empty Repository.readable_in_org(@acme_corporation)
  end

  def test_any_readable_in_org?
    refute Repository.any_readable_in_org?(@acme_corporation)
  end

end
