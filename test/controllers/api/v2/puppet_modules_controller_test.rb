require "katello_test_helper"

module Katello
  class Api::V2::PuppetModulesControllerTest < ActionController::TestCase
    def models
      @library = katello_environments(:library)
      @repo = Repository.find(katello_repositories(:p_forge).id)
      @puppet_module = katello_puppet_modules(:dhcp)
    end

    def permissions
      @read_permission = :view_products
      @create_permission = :create_products
      @update_permission = :edit_products
      @destroy_permission = :destroy_products
      @sync_permission = :sync_products

      @auth_permissions = [@read_permission, :view_content_views]
      @unauth_permissions = [@create_permission, @update_permission, @destroy_permission, @sync_permission]
    end

    def setup
      setup_controller_defaults_api
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      models
      permissions
    end

    def test_index_by_env
      get :index, :environment_id => @library.id

      assert_response :success
      assert_template "katello/api/v2/puppet_modules/index"
    end

    def test_index_by_repo
      get :index, :repository_id => @repo.id

      assert_response :success
      assert_template "katello/api/v2/puppet_modules/index"
    end

    def test_index_with_environment_id
      environment = KTEnvironment.first

      get :index, :environment_id => environment.id

      assert_response :success
      assert_template "katello/api/v2/puppet_modules/index"
    end

    def test_index_with_content_view_version
      dev_puppet_env = katello_content_view_puppet_environments(:dev_view_puppet_environment)
      ContentViewPuppetEnvironment.stubs(:archived).returns([dev_puppet_env])

      get :index, :environment_id => dev_puppet_env.environment_id,
          :content_view_version_id => dev_puppet_env.content_view_version.id

      assert_response :success
      results_puppet_module = JSON.parse(response.body)['results'].first

      # the content view version in the dev puppet environment only has the 'dhcp' puppet module,
      # which is the same as @puppet_module
      assert_equal results_puppet_module['name'], @puppet_module.name
      assert_equal results_puppet_module['author'], @puppet_module.author
      assert_equal results_puppet_module['version'], @puppet_module.version
    end

    def test_index_protected
      assert_protected_action(:index, @read_permission, @unauth_permissions) do
        get :index, :repository_id => @repo.id
      end
    end

    def test_show
      Katello::Pulp::PuppetModule.any_instance.stubs(:backend_data).returns({})
      get :show, :repository_id => @repo.id, :id => @puppet_module.id

      assert_response :success
      assert_template "katello/api/v2/puppet_modules/show"
    end

    def test_show_protected
      assert_protected_action(:show, @read_permission, @unauth_permissions) do
        get :show, :repository_id => @repo.id, :id => @puppet_module.id
      end
    end

    def test_show_module_not_in_repo
      get :show, :repository_id => @repo.id, :id => "abc-123"
      assert_response 404
    end

    def test_show_module_not_found
      get :show, :repository_id => @repo.id, :id => "abc-123"
      assert_response 404
    end
  end
end
