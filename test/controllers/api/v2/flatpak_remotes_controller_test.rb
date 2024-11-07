require 'katello_test_helper'

module Katello
  class Api::V2::FlatpakRemotesControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task
    def models
      @organization = get_organization
      @remote = katello_flatpak_remotes(:redhat_flatpak_remote)
    end

    def permissions
      @view_permission = :view_flatpak_remotes
      @create_permission = :create_flatpak_remotes
      @update_permission = :edit_flatpak_remotes
      @destroy_permission = :destroy_flatpak_remotes
    end

    def setup
      setup_controller_defaults_api
      models
      permissions
    end

    def test_index
      get :index

      assert_response :success
      assert_template 'api/v2/flatpak_remotes/index'
    end

    def test_index_with_name
      response = get :index, params: { name: @remote.name }

      assert_response :success
      assert_template 'api/v2/flatpak_remotes/index'
      assert_response_ids response, [@remote.id]
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms, [@organization]) do
        get :index, params: { :organization_id => @organization.id }
      end
    end

    def test_show
      get :show, params: { :id => @remote.id }

      assert_response :success
      assert_template 'api/v2/flatpak_remotes/show'
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, params: { :id => @remote.id }
      end
    end

    def test_create
      post :create, params: { name: 'test', url: 'https://test.com', organization_id: @organization.id }

      assert_response :success
      assert_template 'api/v2/common/create'
    end

    def test_create_protected
      allowed_perms = [@create_permission]
      denied_perms = [@view_permission, @update_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms, [@organization]) do
        post :create, params: { name: 'test', url: 'https://test.com', organization_id: @organization.id }
      end
    end

    def test_update
      put :update, params: { id: @remote.id, name: 'test' }

      assert_response :success
      assert_template 'api/v2/flatpak_remotes/show'
    end

    def test_destroy
      delete :destroy, params: { id: @remote.id }

      assert_response :success
    end

    def test_scan
      post :scan, params: { id: @remote.id }

      assert_response :success
      assert_template 'api/v2/common/async'
    end

    def test_scan_protected
      allowed_perms = [@update_permission]
      denied_perms = [@create_permission, @view_permission, @destroy_permission]

      assert_protected_action(:scan, allowed_perms, denied_perms) do
        post :scan, params: { id: @remote.id }
      end
    end
  end
end
