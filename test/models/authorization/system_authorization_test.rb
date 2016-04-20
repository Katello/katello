require 'models/authorization/authorization_base'

module Katello
  class SystemAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('admin').id)
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
      sys = System.find(katello_systems(:simple_server_3).id)
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
      User.current = User.find(users('restricted').id)
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
      sys = System.find(katello_systems(:simple_server_3).id)
      refute System.all_editable?(sys.content_view, sys.environment)
    end
  end

  class SystemAuthorizationWithPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted').id)
    end

    def test_all_editable?
      sys = System.find(katello_systems(:simple_server_3).id)
      systems = System.where(:content_view_id => sys.content_view_id, :environment_id => sys.environment)

      clause = systems.map { |system| "name=\"#{system.name}\"" }.join(" or ")

      setup_current_user_with_permissions(:name => "edit_content_hosts",
                                          :search => clause)
      assert System.all_editable?(sys.content_view, sys.environment)
    end
  end
end
