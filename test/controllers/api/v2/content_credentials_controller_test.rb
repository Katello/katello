require "katello_test_helper"
require 'tempfile'

module Katello
  class Api::V2::ContentCredentialsControllerTest < ActionController::TestCase
    def models
      @organization = get_organization
      @product = Product.find(katello_products(:fedora).id)
      @gpg_key = GpgKey.find(katello_gpg_keys(:fedora_gpg_key).id)
      @cert = GpgKey.find(katello_gpg_keys(:fedora_cert).id)
    end

    def permissions
      @resource_type = "Katello::GpgKey"
      @view_permission = :view_content_credentials
      @create_permission = :create_content_credentials
      @update_permission = :edit_content_credentials
      @destroy_permission = :destroy_content_credentials
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      User.current = User.find(users(:admin).id)
      models
      permissions
    end

    def test_index
      get :index, params: { :organization_id => @organization.id }

      assert_response :success
      assert_template 'api/v2/content_credentials/index'
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms, [@organization]) do
        get :index, params: { :organization_id => @organization.id }
      end
    end

    def test_content
      get :content, params: { :id => @gpg_key.id }
      assert_response :success
      assert_equal @response.body, @gpg_key.content
    end

    def test_set_content
      @request.env["CONTENT_TYPE"] = "multipart/form"
      content = "abc123"
      temp_content_file = Tempfile.new(content)
      temp_content_file.write(content)
      temp_content_file.rewind
      post :set_content, params: { :id => @gpg_key.id, :content_type => "gpg_key", :content => Rack::Test::UploadedFile.new(temp_content_file.path, "text/plain") }
      assert_response :success, @response.body
      assert_equal content, @gpg_key.reload.content
    end

    def test_cert_content
      @request.env["CONTENT_TYPE"] = "multipart/form"
      content = "my awesome cert"
      temp_content_file = Tempfile.new(content)
      temp_content_file.write(content)
      temp_content_file.rewind
      post :set_content, params: { :id => @cert.id, :content_type => "cert", :content => Rack::Test::UploadedFile.new(temp_content_file.path, "text/plain") }
      assert_response :success, @response.body
      assert_equal content, @cert.reload.content
    end

    def test_create
      test_key_name = "testkey"
      content = "abc123"
      temp_content_file = Tempfile.new(content)
      temp_content_file.write(content)
      temp_content_file.rewind
      uploaded_file = Rack::Test::UploadedFile.new(temp_content_file.path, "text/plain")
      post :create, params: { :organization_id => @organization.id, :name => test_key_name, :content_type => "gpg_key", :content => uploaded_file}
      assert_response :success
    end

    def test_create_existing_name
      content = "abc123"
      temp_content_file = Tempfile.new(content)
      temp_content_file.write(content)
      temp_content_file.rewind
      uploaded_file = Rack::Test::UploadedFile.new(temp_content_file.path, "text/plain")
      post :create, params: { :organization_id => @organization.id, :name => @gpg_key.name, :content_type => "gpg_key", :content => uploaded_file }
      assert_response 422, @response.body
      response = JSON.parse(@response.body)
      assert_equal response["displayMessage"], "Validation failed: Name has already been taken"
    end

    def test_create_invalid_content
      post :create, params: { :organization_id => @organization.id, :name => "newame"}
      assert_response 422, @response.body
      response = JSON.parse(@response.body)
      assert_equal response["displayMessage"], "Validation failed: Content can't be blank"
    end

    def test_create_invalid_name
      content = "abc123"
      temp_content_file = Tempfile.new(content)
      temp_content_file.write(content)
      temp_content_file.rewind
      uploaded_file = Rack::Test::UploadedFile.new(temp_content_file.path, "text/plain")
      post :create, params: { :organization_id => @organization.id, :name => "\t", :content_type => "gpg_key", :content => uploaded_file}
      assert_response 422, @response.body
      response = JSON.parse(@response.body)
      assert_equal response["displayMessage"], "Validation failed: Name can't be blank, Name must contain at least 1 character"
    end

    def test_update
      test_key_name = "testkey"
      new_content = "abc123"
      put :update, params: { :id => @gpg_key.id, :name => test_key_name, :content => new_content }
      assert_response :success
      assert_equal test_key_name, @gpg_key.reload.name
      assert_equal new_content, @gpg_key.reload.content
    end

    def test_update_invalid_name
      put :update, params: { :id => @gpg_key.id, :name => " " }
      assert_response 422, @response.body
      response = JSON.parse(@response.body)
      assert_equal response["displayMessage"], "Validation failed: Name can't be blank, Name must contain at least 1 character"
    end

    def test_update_invalid_content
      put :update, params: { :id => @gpg_key.id, :content => " " }
      assert_response 422, @response.body
      response = JSON.parse(@response.body)
      assert_equal response["displayMessage"], "Validation failed: Content can't be blank"
    end

    def test_destroy
      delete :destroy, params: { :id => @gpg_key.id }
      assert_response :success
    end
  end
end
