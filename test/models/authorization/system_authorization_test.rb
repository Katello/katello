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
  class SystemAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('admin'))
      @sys = @system
      @org = @acme_corporation
      @env = @dev
    end

    def test_readable
      refute_empty System.readable
    end

    def test_readable?
      assert @sys.readable?
    end

    def test_editable?
      assert @sys.editable?
    end

    def test_all_editable?
      sys = System.find(katello_systems(:simple_server_3))
      assert System.all_editable?(sys.content_view, sys.environment)
    end

    def test_deletable?
      assert @sys.deletable?
    end

    def test_any_editable?
      assert System.any_editable?
    end
  end

  class SystemAuthorizationNoPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted'))
      @sys = @system
      @org = @acme_corporation
      @env = @dev
    end

    def test_readable
      assert_empty System.readable
    end

    def test_readable?
      refute @sys.readable?
    end

    def test_editable?
      refute @sys.editable?
    end

    def test_deletable?
      refute @sys.deletable?
    end

    def test_any_editable?
      refute System.any_editable?
    end

    def test_all_editable?
      sys = System.find(katello_systems(:simple_server_3))
      refute System.all_editable?(sys.content_view, sys.environment)
    end
  end

  class SystemAuthorizationWithPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted'))
    end

    def test_all_editable?
      sys = System.find(katello_systems(:simple_server_3))
      systems = System.where(:content_view_id => sys.content_view_id, :environment_id => sys.environment)

      clause = systems.map { |system| "name=\"#{system.name}\"" }.join(" or ")

      setup_current_user_with_permissions(:name => "edit_content_hosts",
                                          :search => clause)
      assert System.all_editable?(sys.content_view, sys.environment)
    end
  end
end
