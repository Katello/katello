require 'models/authorization/authorization_base'

module Katello
  class EnvironmentAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('admin').id)
      @env = @dev
      @org = @acme_corporation
    end

    def test_readable
      refute_empty KTEnvironment.readable
    end

    def test_promotable?
      assert @env.promotable_or_removable?
    end

    def test_promotable
      refute_empty KTEnvironment.promotable
    end

    def test_any_promotable?
      assert KTEnvironment.any_promotable?
    end

    def test_deleteable
      refute_empty KTEnvironment.deletable
    end

    def test_ediable
      refute_empty KTEnvironment.editable
    end
  end

  class EnvironmentAuthorizationNoPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted').id)
      @env = @dev
      @org = @acme_corporation
    end

    def test_readable
      assert_empty KTEnvironment.readable
    end

    def test_promotable?
      refute @env.promotable_or_removable?
    end

    def test_promotable
      assert_empty KTEnvironment.promotable
    end

    def test_any_promotable?
      refute KTEnvironment.any_promotable?
    end

    def test_deletable
      assert_empty KTEnvironment.deletable
    end

    def test_editable
      assert_empty KTEnvironment.editable
    end
  end

  class EnvironmentAuthorizationWithPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted').id)
    end

    def test_readables
      environment = katello_environments(:staging_path1)
      setup_current_user_with_permissions({ :name => "view_lifecycle_environments",
                                            :search => "name=\"#{environment.name}\"" })
      assert_equal([environment.id], KTEnvironment.readable.pluck(:id))
      assert environment.readable?
      refute environment.prior.readable?
    end

    def test_promotables
      environment = katello_environments(:staging_path1)
      setup_current_user_with_permissions({ :name => "promote_or_remove_content_views_to_environments",
                                            :search => "name=\"#{environment.name}\"" })
      assert_equal([environment.id], KTEnvironment.promotable.pluck(:id))
      assert environment.promotable_or_removable?
      refute environment.prior.promotable_or_removable?
    end
  end
end
