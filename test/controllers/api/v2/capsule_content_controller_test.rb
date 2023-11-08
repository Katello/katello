# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::CapsuleContentControllerTest < ActionController::TestCase
    include Support::CapsuleSupport
    include Support::ForemanTasks::Task

    def setup
      setup_controller_defaults_api
      @repository = katello_repositories(:fedora_17_unpublished)
      @library_dev_view = ContentView.find(katello_content_views(:library_dev_view).id)
    end

    def allowed_perms
      [[:view_capsule_content, :manage_capsule_content]]
    end

    def view_allowed_perms
      [:view_capsule_content]
    end

    def denied_perms
      []
    end

    def environment
      @environment ||= katello_environments(:library)
    end

    def test_lifecycle_environments
      get :lifecycle_environments, params: { :id => proxy_with_pulp.id }
      assert_response :success
    end

    def test_lifecycle_environments_protected
      assert_protected_action(:lifecycle_environments, view_allowed_perms, denied_perms) do
        get :lifecycle_environments, params: { :id => proxy_with_pulp.id }
      end
    end

    def test_available_lifecycle_environments
      get :available_lifecycle_environments, params: { :id => proxy_with_pulp.id }
      assert_response :success
    end

    def test_available_lifecycle_environments_protected
      assert_protected_action(:available_lifecycle_environments, view_allowed_perms, denied_perms) do
        get :available_lifecycle_environments, params: { :id => proxy_with_pulp.id }
      end
    end

    def test_add_lifecycle_environment
      post :add_lifecycle_environment, params: { :id => proxy_with_pulp.id, :environment_id => environment.id }
      assert_response :success
    end

    def test_add_lifecycle_environment_protected
      assert_protected_action(:add_lifecycle_environment, [[:view_capsule_content, :manage_capsule_content, :view_lifecycle_environments]], denied_perms) do
        post :add_lifecycle_environment, params: { :id => proxy_with_pulp.id, :environment_id => environment.id }
      end
    end

    def test_remove_lifecycle_environment
      capsule_content.smart_proxy.add_lifecycle_environment(environment)

      delete :remove_lifecycle_environment, params: { :id => proxy_with_pulp.id, :environment_id => environment.id }
      assert_response :success
    end

    def test_remove_lifecycle_environment_protected
      assert_protected_action(:remove_lifecycle_environment, [[:view_capsule_content, :manage_capsule_content, :view_lifecycle_environments]], denied_perms) do
        delete :remove_lifecycle_environment, params: { :id => proxy_with_pulp.id, :environment_id => environment.id }
      end
    end

    def test_sync
      assert_async_task ::Actions::Katello::CapsuleContent::Sync do |capsule, options|
        assert_equal proxy_with_pulp.id, capsule.id
        assert_equal options[:environment_id], environment.id
      end

      post :sync, params: { :id => proxy_with_pulp.id, :environment_id => environment.id }
      assert_response :success
    end

    def test_sync_with_repo
      assert_async_task ::Actions::Katello::CapsuleContent::Sync do |capsule, options|
        assert_equal proxy_with_pulp.id, capsule.id
        assert_equal options[:repository_id], @repository.id
      end

      post :sync, params: { :id => proxy_with_pulp.id, :repository_id => @repository.id }
      assert_response :success
    end

    def test_sync_with_cv
      assert_async_task ::Actions::Katello::CapsuleContent::Sync do |capsule, options|
        assert_equal proxy_with_pulp.id, capsule.id
        assert_equal options[:content_view_id], @library_dev_view.id
      end

      post :sync, params: { :id => proxy_with_pulp.id, :content_view_id => @library_dev_view.id }
      assert_response :success
    end

    def test_sync_protected
      assert_protected_action(:sync, allowed_perms, denied_perms) do
        post :sync, params: { :id => proxy_with_pulp.id, :environment_id => environment.id }
      end
    end

    def test_sync_status
      get :sync_status, params: { :id => proxy_with_pulp.id }
      assert_response :success
    end

    def test_sync_status_protected
      assert_protected_action(:sync, view_allowed_perms, denied_perms) do
        get :sync_status, params: { :id => proxy_with_pulp.id }
      end
    end

    def test_cancel_sync
      get :cancel_sync, params: { :id => proxy_with_pulp.id }
      assert_response :success
    end

    def test_cancel_sync_protected
      assert_protected_action(:sync, allowed_perms, denied_perms) do
        get :cancel_sync, params: { :id => proxy_with_pulp.id }
      end
    end

    def test_update_counts
      assert_async_task ::Actions::Katello::CapsuleContent::UpdateContentCounts do |capsule|
        assert_equal proxy_with_pulp.id, capsule.id
      end

      post :update_counts, params: { :id => proxy_with_pulp.id }
      assert_response :success
    end

    def test_counts
      SmartProxy.any_instance.expects(:content_counts).once
      get :counts, params: { :id => proxy_with_pulp.id }
      assert_response :success
    end

    def test_reclaim_space
      assert_async_task ::Actions::Pulp3::CapsuleContent::ReclaimSpace do |capsule|
        assert_equal proxy_with_pulp.id, capsule.id
      end

      post :reclaim_space, params: { :id => proxy_with_pulp.id }
      assert_response :success
    end

    def test_validate_content
      assert_async_task ::Actions::Pulp3::CapsuleContent::ValidateContent do |capsule|
        assert_equal proxy_with_pulp.id, capsule.id
      end

      post :validate_content, params: { :id => proxy_with_pulp.id }
      assert_response :success
    end
  end
end
