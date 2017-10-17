require "katello_test_helper"
require 'tempfile'

module Katello
  class Api::V2::GpgKeysControllerTest < ActionController::TestCase
    def models
      @organization = get_organization
      @product = Product.find(katello_products(:fedora).id)
      @gpg_key = GpgKey.find(katello_gpg_keys(:fedora_gpg_key).id)
    end

    def permissions
      @resource_type = "Katello::GpgKey"
      @view_permission = :view_gpg_keys
      @create_permission = :create_gpg_keys
      @update_permission = :edit_gpg_keys
      @destroy_permission = :destroy_gpg_keys
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin).id))
      User.current = User.find(users(:admin).id)
      models
      permissions
    end

    def test_index
      get :index, :organization_id => @organization.id

      assert_response :success
      assert_template 'api/v2/gpg_keys/index'
    end

    def test_index_protected
      allowed_perms = [@view_permission]
      denied_perms = [@create_permission, @update_permission, @destroy_permission]

      assert_protected_action(:index, allowed_perms, denied_perms, [@organization]) do
        get :index, :organization_id => @organization.id
      end
    end

    def test_content
      @request.env["CONTENT_TYPE"] = "multipart/form"
      content = "abc123"
      temp_content_file = Tempfile.new(content)
      temp_content_file.write(content)
      temp_content_file.rewind
      post :content, :id => @gpg_key.id, :content => Rack::Test::UploadedFile.new(temp_content_file.path, "text/plain")
      assert_response :success, @response.body
      assert_equal content, @gpg_key.reload.content
    end
  end
end
