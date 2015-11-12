require 'models/authorization/authorization_base'

module Katello
  class ContentViewAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('admin'))
      @view = ContentView.find(katello_content_views('acme_default'))
    end

    def test_readable
      refute_empty ContentView.readable
    end

    def test_content_view_readable?
      assert @view.readable?
    end

    def test_content_view_editable?
      assert @view.editable?
    end

    def test_content_view_deletable?
      assert @view.deletable?
    end

    def test_content_view_publishable?
      assert @view.publishable?
    end

    def test_promotable?
      assert @view.promotable_or_removable?
    end

    def test_readable_repositories
      refute_empty ContentView.readable_repositories
    end

    def test_readable_repositories_with_ids
      refute_empty ContentView.readable_repositories([Repository.first.id])
    end
  end

  class ContentViewAuthorizationNoPermsTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users('restricted'))
      @view = ContentView.find(katello_content_views('acme_default'))
    end

    def test_readable
      assert_empty ContentView.readable
    end

    def test_content_view_readable?
      refute @view.readable?
    end

    def test_content_view_editable?
      refute @view.editable?
    end

    def test_content_view_deletable?
      refute @view.deletable?
    end

    def test_content_view_publishable?
      refute @view.publishable?
    end

    def test_promotable?
      refute @view.promotable_or_removable?
    end

    def test_promotable_perm
      cv = katello_content_views(:library_dev_staging_view)
      refute cv.promotable_or_removable?
    end

    def test_readable_repositories
      assert_empty ContentView.readable_repositories
    end

    def test_readable_repositories_with_ids
      assert_empty ContentView.readable_repositories([Repository.first.id])
    end
  end
end
