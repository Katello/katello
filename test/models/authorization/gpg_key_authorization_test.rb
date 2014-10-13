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
  class GpgKeyAuthorizationAdminTest < AuthorizationTestBase

    def setup
      super
      User.current = User.find(users('admin'))
      @key = GpgKey.find(katello_gpg_keys('fedora_gpg_key'))
    end

    def test_readable
      refute_empty GpgKey.readable
    end

    def test_key_readable?
      assert @key.readable?
    end

    def test_key_editable?
      assert @key.editable?
    end

    def test_key_deletable?
      assert @key.deletable?
    end
  end

  class GpgKeyAuthorizationNoPermsTest < AuthorizationTestBase

    def setup
      super
      User.current = User.find(users('restricted'))
      @key = GpgKey.find(katello_gpg_keys('fedora_gpg_key'))
    end

    def test_readable
      assert_empty GpgKey.readable
    end

    def test_key_readable?
      refute @key.readable?
    end

    def test_key_editable?
      refute @key.editable?
    end

    def test_key_deletable?
      refute @key.deletable?
    end

  end
end
