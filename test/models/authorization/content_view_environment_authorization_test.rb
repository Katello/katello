require 'models/authorization/authorization_base'

module Katello
  class ContentViewEnvironmentAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users(:admin).id)
      @content_view_environment = katello_content_view_environments(:library_default_view_environment)
    end

    def test_readable?
      assert @content_view_environment.readable?
    end
  end

  class ContentViewEnvironmentAuthorizationNonAuthUserTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users(:restricted).id)
      @content_view_environment = katello_content_view_environments(:library_default_view_environment)
    end

    def test_readable?
      refute @content_view_environment.readable?
    end
  end

  class ContentViewEnvironmentAuthorizationAuthorizedUserTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users(:restricted).id)
      @content_view_environment = katello_content_view_environments(:library_default_view_environment)
    end

    def test_readable?
      setup_current_user_with_permissions([:view_content_views, :view_lifecycle_environments])
      assert @content_view_environment.readable?
    end
  end
end
