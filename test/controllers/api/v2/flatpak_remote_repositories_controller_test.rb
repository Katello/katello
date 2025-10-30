require 'katello_test_helper'

module Katello
  class Api::V2::FlatpakRemoteRepositoriesControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task
    def models
      @organization = get_organization
      @product = katello_products(:empty_product)
      @remote = katello_flatpak_remotes(:redhat_flatpak_remote)
      @redhat_remote_runtime_repository = katello_flatpak_remote_repositories(:rhel9_flatpak_runtime)
      @redhat_remote_firefox_repository = katello_flatpak_remote_repositories(:rhel9_firefox_flatpak)
    end

    def permissions
      @view_permission = :view_flatpak_remotes
      @create_permission = :create_flatpak_remotes
      @update_permission = :edit_flatpak_remotes
      @destroy_permission = :destroy_flatpak_remotes
      @product_edit_permission = :edit_products
    end

    def setup
      setup_controller_defaults_api
      models
      permissions
    end

    def test_index
      get :index
      assert_response :success
      assert_template 'api/v2/flatpak_remote_repositories/index'
    end

    def test_index_with_name
      response = get :index, params: { name: @redhat_remote_runtime_repository.name }

      assert_response :success
      assert_template 'api/v2/flatpak_remote_repositories/index'
      assert_response_ids response, [@redhat_remote_runtime_repository.id]
    end

    def test_index_with_remote
      response = get :index, params: { flatpak_remote_id: @remote.id }

      assert_response :success
      assert_template 'api/v2/flatpak_remote_repositories/index'
      assert_response_ids response, [@redhat_remote_runtime_repository.id, @redhat_remote_firefox_repository.id]
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms, [@organization]) do
        get :index, params: { :organization_id => @organization.id }
      end
    end

    def test_show
      get :show, params: { :id => @redhat_remote_runtime_repository.id }

      assert_response :success
      assert_template 'api/v2/flatpak_remote_repositories/show'
    end

    def test_show_with_manifest
      get :show, params: { :id => @redhat_remote_runtime_repository.id, :manifests => true }

      assert_response :success
      assert_template 'api/v2/flatpak_remote_repositories/show'
    end

    def test_show_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:show, allowed_perms, denied_perms) do
        get :show, params: { :id => @redhat_remote_runtime_repository.id }
      end
    end

    def test_mirror_product_id
      post :mirror, params: { :id => @redhat_remote_runtime_repository.id, :product_id => @product.id }

      assert_response :success
      assert_template 'api/v2/common/async'
    end

    def test_mirror_product_name
      post :mirror, params: {
        :id => @redhat_remote_runtime_repository.id,
        :product_name => @product.name,
        :organization_id => @organization.id,
      }

      assert_response :success
      assert_template 'api/v2/common/async'
    end

    def test_mirror_protected
      allowed_perms = [@product_edit_permission]
      denied_perms = [@create_permission, @view_permission, @update_permission, @destroy_permission]

      assert_protected_action(:mirror, allowed_perms, denied_perms, [@organization]) do
        post :mirror, params: { :id => @redhat_remote_runtime_repository.id, :product_id => @product.id }
      end
    end

    def test_mirror_product_missing
      post :mirror, params: { :id => @redhat_remote_runtime_repository.id }

      assert_response :bad_request
      response_body = JSON.parse(response.body)
      assert_match(/Product must be specified/, response_body['displayMessage'])
    end

    def test_mirror_product_name_organization_missing
      post :mirror, params: {
        :id => @redhat_remote_runtime_repository.id,
        :product_name => @product.name,
      }

      assert_response :bad_request
      response_body = JSON.parse(response.body)
      assert_match(/Organization must be specified when providing product by name/, response_body['displayMessage'])
    end

    def test_mirror_product_id_invalid
      post :mirror, params: {
        :id => @redhat_remote_runtime_repository.id,
        :product_id => 999,
      }

      assert_response :not_found
    end

    def test_mirror_product_name_invalid
      post :mirror, params: {
        :id => @redhat_remote_runtime_repository.id,
        :product_name => 'nonexistent_product',
        :organization_id => @organization.id,
      }

      assert_response :not_found
      response_body = JSON.parse(response.body)
      assert_match(/Could not find product/, response_body['displayMessage'])
    end

    def test_mirror_product_redhat
      redhat_product = katello_products(:redhat)
      post :mirror, params: {
        :id => @redhat_remote_runtime_repository.id,
        :product_id => redhat_product.id,
      }

      assert_response :unprocessable_entity
      response_body = JSON.parse(response.body)
      assert_match(/cannot be mirrored into Red Hat products/, response_body['displayMessage'])
    end
  end
end
