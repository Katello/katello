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

    def test_promoted_deletable?
      repository = Repository.find(katello_repositories(:fedora_17_x86_64_library_view_1).id)
      repository.stubs(:promoted?).returns(true)
      assert repository.deletable?
    end

    def test_redhat_deletable?
      repository = Repository.find(katello_repositories(:rhel_7_x86_64).id)
      assert repository.redhat_deletable?
    end

    def test_promoted_redhat_repo_not_deletable
      repository = Repository.find(katello_repositories(:rhel_7_x86_64).id)
      repository.stubs(:promoted?).returns(true)
      refute repository.redhat_deletable?
      assert repository.redhat_deletable?(true)
    end

    def test_generated_cv_redhat_repo_deletable
      repository = Repository.find(katello_repositories(:rhel_7_x86_64).id)
      repository.stubs(:promoted?).returns(true)
      content_views = Katello::ContentView.where(id: katello_content_views(:library_dev_staging_view).id)
      repository.stubs(:content_views_all).returns(content_views)
      content_views.first.generated_for_repository_export!
      assert repository.content_views_all(include_composite: true).exists?
      refute repository.content_views.generated_for_none.exists?
      assert repository.redhat_deletable?
    end

    def test_cv_redhat_repo_not_deletable
      repository = Repository.find(katello_repositories(:rhel_7_x86_64).id)
      repository.stubs(:promoted?).returns(true)
      content_views = Katello::ContentView.where(id: katello_content_views(:library_dev_staging_view).id)
      repository.stubs(:content_views).returns(content_views)
      assert repository.content_views.exists?
      assert repository.content_views.generated_for_none.exists?
      refute repository.redhat_deletable?
      assert repository.redhat_deletable?(true)
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
      setup_current_user_with_permissions({ :name => "view_products", :search => nil })
      assert_includes Repository.readable, @fedora_17_x86_64
    end

    def test_readable_with_content_view
      refute_includes Repository.readable, @fedora_17_x86_64
      setup_current_user_with_permissions({ :name => "view_content_views", :search => nil })
      assert_includes Repository.readable, @fedora_17_x86_64
    end

    def test_readable_with_versions
      refute_includes Repository.readable, @fedora_17_x86_64_dev
      setup_current_user_with_permissions({ :name => "view_content_views", :search => "name = \"#{@fedora_17_x86_64_dev.content_view_version.content_view.name}\"" })
      assert_includes Repository.readable, @fedora_17_x86_64_dev
    end

    def test_readable_with_environment
      refute_includes Repository.readable, @fedora_17_x86_64
      setup_current_user_with_permissions({ :name => "view_lifecycle_environments", :search => "name = \"#{@fedora_17_x86_64.environment.name}\"" })
      repos = Repository.readable
      refute_empty repos
      assert repos.all? { |repo| repo.environment_id == @fedora_17_x86_64.environment_id }
    end

    def test_deletable
      assert_empty Repository.deletable
    end
  end
end
