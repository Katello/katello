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
      login_user(User.find(users(:admin)))
      User.current = User.find(users(:admin))
      models
      permissions
    end

    def test_destroy_repositories
      assert_async_task(::Actions::BulkAction) do |action_class|
        action_class.must_equal ::Actions::Katello::Repository::Destroy
      end

      put :destroy_repositories, :ids => @repositories.collect(&:id), :organization_id => @organization.id

      assert_response :success
    end

    def test_destroy_repositories_protected
      allowed_perms = [@destroy_permission]
      denied_perms = [@sync_permission, @read_permission, @create_permission, @update_permission]

      assert_protected_action(:destroy_repositories, allowed_perms, denied_perms) do
        put :destroy_repositories, :ids => @repositories.collect(&:id), :organization_id => @organization.id
      end
    end

    def test_sync
      assert_async_task(::Actions::BulkAction) do |action_class, repos|
        action_class.must_equal ::Actions::Katello::Repository::Sync
        repos.map(&:id).sort.must_equal @repositories.map(&:id).sort
      end

      post :sync_repositories, :ids => @repositories.collect(&:id), :organization_id => @organization.id

      assert_response :success
    end

    def test_sync_feedless
      repo_with_feed = katello_repositories(:fedora_17_x86_64)
      repo_with_no_feed = katello_repositories(:feedless_fedora_17_x86_64)
      assert_async_task(::Actions::BulkAction) do |action_class, repos|
        action_class.must_equal ::Actions::Katello::Repository::Sync
        repos.map(&:id).must_equal [repo_with_feed.id]
      end

      post :sync_repositories, :ids => [repo_with_feed, repo_with_no_feed].collect(&:id), :organization_id => @organization.id

      assert_response :success
    end

    def test_sync_protected
      allowed_perms = [@sync_permission]
      denied_perms = [@destroy_permission, @read_permission, @create_permission, @update_permission]

      assert_protected_action(:sync_repositories, allowed_perms, denied_perms) do
        post :sync_repositories, :ids => @repositories.collect(&:id), :organization_id => @organization.id
      end
    end
  end
end
