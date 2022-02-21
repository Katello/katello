require "katello_test_helper"

module Katello
  class Api::V2::RepositoriesBulkActionsControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def models
      @organization = get_organization
      @repositories = katello_repositories(:fedora_17_unpublished, :fedora_17_unpublished_2)
      @provider = katello_providers(:fedora_hosted)
    end

    def permissions
      @read_permission = :view_products
      @create_permission = :create_products
      @update_permission = :edit_products
      @destroy_permission = :destroy_products
      @sync_permission = :sync_products
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      User.current = User.find(users(:admin).id)
      models
      permissions
    end

    def test_destroy_repositories
      assert_async_task(::Actions::BulkAction) do |action_class|
        assert_equal action_class, ::Actions::Katello::Repository::Destroy
      end

      put :destroy_repositories, params: { :ids => @repositories.collect(&:id), :organization_id => @organization.id }

      assert_response :success
    end

    def test_destroy_repositories_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@sync_permission, @read_permission, @create_permission, @update_permission]

      assert_protected_action(:destroy_repositories, allowed_perms, denied_perms, [@organization]) do
        put :destroy_repositories, params: { :ids => @repositories.collect(&:id), :organization_id => @organization.id }
      end
    end

    def test_sync
      assert_async_task(::Actions::BulkAction) do |action_class, repos|
        assert_equal action_class, ::Actions::Katello::Repository::Sync
        assert_equal @repositories.map(&:id).sort, repos.map(&:id).sort
      end

      post :sync_repositories, params: { :ids => @repositories.collect(&:id), :organization_id => @organization.id }

      assert_response :success
    end

    def test_sync_feedless
      repo_with_feed = katello_repositories(:fedora_17_x86_64)
      repo_with_no_feed = katello_repositories(:feedless_fedora_17_x86_64)
      assert_async_task(::Actions::BulkAction) do |action_class, repos|
        assert_equal action_class, ::Actions::Katello::Repository::Sync
        assert_equal repos.map(&:id), [repo_with_feed.id]
      end

      post :sync_repositories, params: { :ids => [repo_with_feed, repo_with_no_feed].collect(&:id), :organization_id => @organization.id }

      assert_response :success
    end

    def test_sync_protected
      allowed_perms = [@sync_permission]
      denied_perms = [@destroy_permission, @read_permission, @create_permission, @update_permission]

      assert_protected_action(:sync_repositories, allowed_perms, denied_perms, [@organization]) do
        post :sync_repositories, params: { :ids => @repositories.collect(&:id), :organization_id => @organization.id }
      end
    end

    def test_reclaim_space
      assert_async_task(::Actions::BulkAction) do |action_class, repos|
        assert_equal action_class, ::Actions::Pulp3::Repository::ReclaimSpace
        assert_equal @repositories.select { |repo| repo.download_policy == ::Katello::RootRepository::DOWNLOAD_ON_DEMAND }.map(&:id).sort,
                     repos.select { |repo| repo.download_policy == ::Katello::RootRepository::DOWNLOAD_ON_DEMAND }.map(&:id).sort
      end

      post :reclaim_space_from_repositories, params: { :ids => @repositories.collect(&:id), :organization_id => @organization.id }

      assert_response :success
    end
  end
end
