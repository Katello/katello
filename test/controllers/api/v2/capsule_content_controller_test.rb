# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::CapsuleContentControllerTest < ActionController::TestCase
    include Support::CapsuleSupport
    include Support::ForemanTasks::Task

    def setup
      Katello::PuppetModule.stubs(:module_count).returns(0)
      setup_controller_defaults_api
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
      get :lifecycle_environments, :id => proxy_with_pulp.id
      assert_response :success
    end

    def test_lifecycle_environments_protected
      assert_protected_action(:lifecycle_environments, view_allowed_perms, denied_perms) do
        get :lifecycle_environments, :id => proxy_with_pulp.id
      end
    end

    def test_available_lifecycle_environments
      get :available_lifecycle_environments, :id => proxy_with_pulp.id
      assert_response :success
    end

    def test_available_lifecycle_environments_protected
      assert_protected_action(:available_lifecycle_environments, view_allowed_perms, denied_perms) do
        get :available_lifecycle_environments, :id => proxy_with_pulp.id
      end
    end

    def test_add_lifecycle_environment
      post :add_lifecycle_environment, :id => proxy_with_pulp.id, :environment_id => environment.id
      assert_response :success
    end

    def test_add_lifecycle_environment_protected
      assert_protected_action(:add_lifecycle_environment, [[:view_capsule_content, :manage_capsule_content, :view_lifecycle_environments]], denied_perms) do
        post :add_lifecycle_environment, :id => proxy_with_pulp.id, :environment_id => environment.id
      end
    end

    def test_remove_lifecycle_environment
      capsule_content.add_lifecycle_environment(environment)

      delete :remove_lifecycle_environment, :id => proxy_with_pulp.id, :environment_id => environment.id
      assert_response :success
    end

    def test_remove_lifecycle_environment_protected
      assert_protected_action(:remove_lifecycle_environment, [[:view_capsule_content, :manage_capsule_content, :view_lifecycle_environments]], denied_perms) do
        delete :remove_lifecycle_environment, :id => proxy_with_pulp.id, :environment_id => environment.id
      end
    end

    def test_sync
      assert_async_task ::Actions::Katello::CapsuleContent::Sync do |capsule, options|
        capsule.id.must_equal proxy_with_pulp.id
        options[:environment_id].must_equal environment.id
      end

      post :sync, :id => proxy_with_pulp.id, :environment_id => environment.id
      assert_response :success
    end

    def test_sync_protected
      assert_protected_action(:sync, allowed_perms, denied_perms) do
        post :sync, :id => proxy_with_pulp.id, :environment_id => environment.id
      end
    end

    def test_sync_status
      get :sync_status, :id => proxy_with_pulp.id
      assert_response :success
    end

    def test_sync_status_protected
      assert_protected_action(:sync, view_allowed_perms, denied_perms) do
        get :sync_status, :id => proxy_with_pulp.id
      end
    end

    def test_cancel_sync
      get :cancel_sync, :id => proxy_with_pulp.id
      assert_response :success
    end

    def test_cancel_sync_protected
      assert_protected_action(:sync, allowed_perms, denied_perms) do
        get :cancel_sync, :id => proxy_with_pulp.id
      end
    end
  end
end
