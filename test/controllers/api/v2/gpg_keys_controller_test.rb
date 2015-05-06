require "katello_test_helper"

module Katello
  class Api::V2::GpgKeysControllerTest < ActionController::TestCase
    def models
      @organization = get_organization
      @product = Product.find(katello_products(:fedora).id)
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
      login_user(User.find(users(:admin)))
      User.current = User.find(users(:admin))
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
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

      assert_protected_action(:index, allowed_perms, denied_perms) do
        get :index, :organization_id => @organization.id
      end
    end
  end
end
