# encoding: utf-8

require "katello_test_helper"

module Katello
  class Api::V2::ContentUploadsControllerTest < ActionController::TestCase
    def models
      @repo = Repository.find(katello_repositories(:fedora_17_x86_64).id)
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
      mock_pulp_server(:create_upload_request => [])
      post :create, params: { :repository_id => @repo.id, :size => 100, :checksum => 'test_checksum' }
      assert_response :success
    end

    def test_create_upload_request_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @create_permission, @destroy_permission]

      assert_protected_action(:create, allowed_perms, denied_perms) do
        post :create, params: { :repository_id => @repo.id }
      end
    end

    def test_update
      mock_pulp_server(:upload_bits => true)
      put :update, params: { :id => "1", :offset => "0", :content => "/tmp/my_file.rpm", :repository_id => @repo.id }

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
      mock_pulp_server(:delete_upload_request => true)
      delete :destroy, params: { :id => "1", :repository_id => @repo.id }

      assert_response :success
    end

    def test_delete_request_protected
      allowed_perms = [@update_permission]
      denied_perms = [@read_permission, @create_permission, @destroy_permission]

      assert_protected_action(:destroy, allowed_perms, denied_perms) do
        delete :destroy, params: { :id => "1", :repository_id => @repo.id }
      end
    end

    private

    def mock_pulp_server(content_hash)
      content = mock(content_hash)
      resources = mock(:content => content)
      pulp_server = mock(:resources => resources)
      pulp_primary = mock(pulp_api: pulp_server, pulp3_support?: false)
      pulp_primary.stubs(:content_service).returns(stub(:content_type => "rpm"))
      SmartProxy.expects(:pulp_primary).at_least_once.returns(pulp_primary)
    end
  end
end
