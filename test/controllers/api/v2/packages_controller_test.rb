require "katello_test_helper"

module Katello
  class Api::V2::PackagesControllerTest < ActionController::TestCase
    def models
      @repo = katello_repositories(:fedora_17_x86_64_dev)
      @version = ContentViewVersion.first
      @rpm = katello_rpms(:one)
      Rpm.any_instance.stubs(:backend_data).returns({})
    end

    def permissions
      @read_permission = :view_products
      @create_permission = :create_products
      @update_permission = :edit_products
      @destroy_permission = :destroy_products
      @sync_permission = :sync_products

      @unauth_permissions = [@create_permission, @update_permission, @destroy_permission, @sync_permission]
    end

    def setup
      setup_controller_defaults_api
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      models
      permissions
    end

    def test_index
      get :index, :repository_id => @repo.id

      assert_response :success
      assert_template "katello/api/v2/packages/index"

      get :index, :content_view_version_id => @version.id

      assert_response :success
      assert_template "katello/api/v2/packages/index"
    end

    def test_index_with_environment_id
      environment = KTEnvironment.first
      KTEnvironment.expects(:readable).returns(stub(:find_by_id => environment))

      get :index, :environment_id => environment.id

      assert_response :success
      assert_template "katello/api/v2/packages/index"
    end

    def test_index_parameters
      get :index

      assert_response :success
    end

    def test_index_protected
      assert_protected_action(:index, @read_permission, @unauth_permissions) do
        get :index, :repository_id => @repo.id
      end
    end

    def test_autocomplete_name
      response = get :auto_complete_name, :repoids => [@repo.id], :term => @rpm.name[0]

      assert_response :success
      assert_includes JSON.parse(response.body), @rpm.name
    end

    def test_show
      get :show, :id => @rpm.id

      assert_response :success
      assert_template "katello/api/v2/packages/show"
    end

    def test_show_uuid
      get :show, :id => @rpm.uuid

      assert_response :success
      assert_template "katello/api/v2/packages/show"
    end

    def test_show_package_not_found
      get :show, :repository_id => @repo.id, :id => "3805853f-5cae-4a4a-8549-0ec86410f58f"
      assert_response 404
    end

    def test_show_protected
      assert_protected_action(:show, @read_permission, @unauth_permissions) do
        get :show, :repository_id => @repo.id, :id => @rpm.uuid
      end
    end
  end
end
