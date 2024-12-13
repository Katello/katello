# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::ContentUploadsControllerTest < ActionController::TestCase
    def models
      @repo = Repository.find(katello_repositories(:fedora_17_x86_64).id)
      @generic_repo = Repository.find(katello_repositories(:pulp3_python_1).id)
      @org = get_organization
      @environment = katello_environments(:library)
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
      models
      permissions
    end

    def test_create_upload_request
      size = 100
      checksum = 'test_checksum'
      @repo.backend_content_service(SmartProxy.pulp_primary).expects(:create_upload).with(size, checksum, 'rpm', @repo)
      ::Katello::RepositoryTypeManager.expects(:check_content_matches_repo_type!).returns(true)
      post :create, params: { :repository_id => @repo.id, :size => 100, :checksum => 'test_checksum', :content_type => nil,
                              :repository => @repo }
      assert_response :success
    end

    def test_create_generic_upload_request
      size = 100
      checksum = 'test_checksum'
      @repo.backend_content_service(SmartProxy.pulp_primary).expects(:create_upload).with(size, checksum, 'python_package', @repo)
      ::Katello::RepositoryTypeManager.expects(:check_content_matches_repo_type!).returns(true)
      post :create, params: { :repository_id => @repo.id, :size => size, :checksum => checksum, :content_type => 'python_package',
                              :repository => @generic_repo }
      assert_response :success
    end

    def test_create_container_upload_request
      container_repo = katello_repositories(:busybox)
      post :create, params: { :repository_id => container_repo.id, :size => 100, :checksum => 'test_checksum2' }
      assert_response :error
      assert_match 'Cannot upload container content via Hammer/API. Use podman push instead.', @response.body
    end

    def test_create_collection_upload_request
      ansible_collection_repo = katello_repositories(:pulp3_ansible_collection_1)
      post :create, params: { :repository_id => ansible_collection_repo.id, :size => 100, :checksum => 'test_checksum' }
      assert_response :error
      assert_match "Cannot upload Ansible collections", @response.body
    end

    def test_create_upload_request_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @create_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, params: { :repository_id => @repo.id }
      end
    end

    def test_update
      id = '1'
      offset = '0'
      content = '/tmp/my_file.rpm'
      @repo.backend_content_service(SmartProxy.pulp_primary).expects(:upload_chunk).with(id, offset, content, nil)
      put :update, params: { :id => id, :offset => offset, :content => content, :repository_id => @repo.id }

      assert_response :success
    end

    def test_update_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @create_permission, @destroy_permission]

      assert_protected_action(:update, allowed_perms, denied_perms) do
        put :update, params: { :id => "1", :offset => "0", :content => "/tmp/my_file.rpm", :repository_id => @repo.id }
      end
    end

    def test_delete_request
      id = '1'
      @repo.backend_content_service(SmartProxy.pulp_primary).expects(:delete_upload).with(id)
      delete :destroy, params: { :id => id, :repository_id => @repo.id }

      assert_response :success
    end

    def test_delete_request_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @create_permission, @destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, params: { :id => "1", :repository_id => @repo.id }
      end
    end
  end
end
