require 'models/authorization/authorization_base'

module Katello
  class ContentViewVersionExportHistoryAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users(:admin).id)
    end

    def test_readable
      refute_empty ContentViewVersionExportHistory.readable
    end
  end

  class ContentViewVersionExportHistoryAuthorizationNonAuthUserTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users(:restricted).id)
    end

    def test_readable
      assert_empty ContentViewVersionExportHistory.readable
    end
  end
end
