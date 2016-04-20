require 'models/authorization/authorization_base'

module Katello
  class ContentViewVersionAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users(:admin).id)
    end

    def test_readable
      refute_empty ContentViewVersion.readable
    end
  end

  class ContentViewVersionAuthorizationNonAuthUserTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users(:restricted).id)
    end

    def test_readable
      assert_empty ContentViewVersion.readable
    end
  end
end
