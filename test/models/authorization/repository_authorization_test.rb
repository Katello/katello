require 'models/authorization/authorization_base'

module Katello
  class RepositoryAuthorizationAdminTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users(:admin).id)
    end

    def test_editable
      assert @fedora_17_x86_64.editable?
    end

    def test_readable?
      assert @fedora_17_x86_64.readable?
    end

    def test_syncable?
      assert @fedora_17_x86_64.syncable?
    end

    def test_deletable?
      repository = Repository.find(katello_repositories(:fedora_17_x86_64_library_view_1).id)
      assert repository.deletable?
    end

    def test_redhat_deletable?
      repository = Repository.find(katello_repositories(:rhel_7_x86_64).id)
      assert repository.redhat_deletable?
    end

    def test_readable
      refute_empty Repository.readable
    end

    def test_deletable
      refute_empty Repository.deletable
    end
  end

  class RepositoryAuthorizationNonAuthUserTest < AuthorizationTestBase
    def setup
      super
      User.current = User.find(users(:restricted).id)
    end

    def test_editable
      refute @fedora_17_x86_64.editable?
    end

    def test_readable?
      refute @fedora_17_x86_64.readable?
    end

    def test_deletable?
      refute @fedora_17_x86_64.deletable?
    end

    def test_syncable?
      refute @fedora_17_x86_64.syncable?
    end

    def test_readable
      assert_empty Repository.readable
    end

    def test_readable_with_product
      refute_includes Repository.readable, @fedora_17_x86_64
      setup_current_user_with_permissions(:name => "view_products", :search => nil)
      assert_includes Repository.readable, @fedora_17_x86_64
    end

    def test_readable_with_content_view
      refute_includes Repository.readable, @fedora_17_x86_64
      setup_current_user_with_permissions(:name => "view_content_views", :search => nil)
      assert_includes Repository.readable, @fedora_17_x86_64
    end

    def test_readable_with_versions
      refute_includes Repository.readable, @fedora_17_x86_64_dev
      setup_current_user_with_permissions(:name => "view_content_views", :search => "name = \"#{@fedora_17_x86_64_dev.content_view_version.content_view.name}\"")
      assert_includes Repository.readable, @fedora_17_x86_64_dev
    end

    def test_deletable
      assert_empty Repository.deletable
    end
  end
end
