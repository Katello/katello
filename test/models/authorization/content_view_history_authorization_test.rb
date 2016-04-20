require 'models/authorization/authorization_base'

module Katello
  class ContentViewHistoryAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('admin').id)
      @history = ContentViewHistory.find(katello_content_view_histories('view_version_1_history_1').id)
    end

    def test_readable
      refute_empty ContentViewHistory.readable
    end
  end

  class ContentViewHistoryAuthorizationNoPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted').id)
      @history = ContentViewHistory.find(katello_content_view_histories('view_version_1_history_1').id)
    end

    def test_readable
      assert_empty ContentViewHistory.readable
    end
  end
end
