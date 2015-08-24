require 'models/authorization/authorization_base'

module Katello
  class ContentViewHistoryAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('admin'))
      @history = ContentViewHistory.find(katello_content_view_histories('view_version_1_history_1'))
    end

    def test_readable
      refute_empty ContentViewHistory.readable
    end
  end

  class ContentViewHistoryAuthorizationNoPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted'))
      @history = ContentViewHistory.find(katello_content_view_histories('view_version_1_history_1'))
    end

    def test_readable
      assert_empty ContentViewHistory.readable
    end
  end
end
