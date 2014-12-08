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
  class RepositoryAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users(:admin))
    end

    def test_editable
      assert @fedora_17_x86_64.editable?
    end

    def test_readable?
      assert @fedora_17_x86_64.readable?
    end

    def test_syncable?
      assert @fedora_17_x86_64.syncable?
    end

    def test_deletable?
      repository = Repository.find(katello_repositories(:fedora_17_x86_64_library_view_1))
      assert repository.deletable?
    end

    def test_redhat_deletable?
      repository = Repository.find(katello_repositories(:rhel_7_x86_64))
      assert repository.redhat_deletable?
    end

    def test_readable
      refute_empty Repository.readable
    end

    def test_deletable
      refute_empty Repository.deletable
    end
  end

  class RepositoryAuthorizationNonAuthUserTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users(:restricted))
    end

    def test_editable
      refute @fedora_17_x86_64.editable?
    end

    def test_readable?
      refute @fedora_17_x86_64.readable?
    end

    def test_deletable?
      refute @fedora_17_x86_64.deletable?
    end

    def test_syncable?
      refute @fedora_17_x86_64.syncable?
    end

    def test_readable
      assert_empty Repository.readable
    end

    def test_deletable
      assert_empty Repository.deletable
    end
  end
end
