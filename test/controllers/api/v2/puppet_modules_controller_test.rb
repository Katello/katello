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
      get :index, params: { :environment_id => @library.id }

      assert_response :success
      assert_template "katello/api/v2/puppet_modules/index"
    end

    test_attributes :pid => 'eafc7a71-d550-4983-9941-b87aa57b83e9'
    def test_index_by_repo_empty_results
      repo = katello_repositories(:dev_p_forge)
      get :index, params: { :repository_id => repo.id }
      assert_response :success
      assert_template "katello/api/v2/puppet_modules/index"
      results = JSON.parse(response.body)
      assert_empty results['results']
    end

    test_attributes :pid => '5337b2be-e207-4580-8407-19b88cb40403'
    def test_index_by_repo_single_result
      repo = katello_repositories(:dev_p_forge)
      repo_puppet_module = RepositoryPuppetModule.new(:repository => repo, :puppet_module => @puppet_module)
      repo_puppet_module.save!
      get :index, params: { :repository_id => repo.id }
      results = JSON.parse(response.body)
      puppet_modules = results['results']
      assert_equal 1, puppet_modules.length
      assert_equal @puppet_module.id, puppet_modules[0]['id']
      assert_equal @puppet_module.name, puppet_modules[0]['name']
    end

    def test_index_by_repo
      get :index, params: { :repository_id => @repo.id }

      assert_response :success
      assert_template "katello/api/v2/puppet_modules/index"
      results = JSON.parse(response.body)
      puppet_modules = results['results']
      refute_empty puppet_modules
      assert_equal %w[abrt dhcp foreman], puppet_modules.map { |pm| pm['name'] }.sort
    end

    def test_index_with_environment_id
      environment = KTEnvironment.first

      get :index, params: { :environment_id => environment.id }

      assert_response :success
      assert_template "katello/api/v2/puppet_modules/index"
    end

    test_attributes :pid => '3a59e2fc-5c95-405e-bf4a-f1fe78e73300'
    def test_index_with_content_view_version_empty_results
      get :index, params: { :content_view_version_id => katello_content_view_versions(:library_view_version_2) }

      assert_response :success
      results = JSON.parse(@response.body)
      assert_empty results['results']
    end

    test_attributes :pid => 'cc358a91-8640-48e3-851d-383e55ba42c3'
    def test_index_with_content_view_version_single_result
      puppet_env = katello_content_view_puppet_environments(:dev_view_puppet_environment)
      ContentViewPuppetEnvironment.stubs(:archived).returns([puppet_env])

      get :index, params: { :content_view_version_id => puppet_env.content_view_version.id }

      assert_response :success
      results = JSON.parse(response.body)
      assert_equal 1, results['results'].length
      puppet_module = results['results'][0]
      assert_equal puppet_module['id'], @puppet_module.id
      assert_equal puppet_module['name'], @puppet_module.name
    end

    def test_index_with_content_view_version
      dev_puppet_env = katello_content_view_puppet_environments(:dev_view_puppet_environment)
      ContentViewPuppetEnvironment.stubs(:archived).returns([dev_puppet_env])

      get :index, params: { :environment_id => dev_puppet_env.environment_id, :content_view_version_id => dev_puppet_env.content_view_version.id }

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
        get :index, params: { :repository_id => @repo.id }
      end
    end

    def test_show
      Katello::Pulp::PuppetModule.any_instance.stubs(:backend_data).returns({})
      get :show, params: { :repository_id => @repo.id, :id => @puppet_module.id }

      assert_response :success
      assert_template "katello/api/v2/puppet_modules/show"
    end

    def test_show_protected
      assert_protected_action(:show, @read_permission, @unauth_permissions) do
        get :show, params: { :repository_id => @repo.id, :id => @puppet_module.id }
      end
    end

    def test_show_module_not_in_repo
      get :show, params: { :repository_id => @repo.id, :id => "abc-123" }
      assert_response 404
    end

    def test_show_module_not_found
      get :show, params: { :repository_id => @repo.id, :id => "abc-123" }
      assert_response 404
    end

    def test_compare
      @lib_repo = katello_repositories(:rhel_6_x86_64)
      @view_repo = katello_repositories(:rhel_6_x86_64_library_view_1)

      get :compare, params: { :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id] }
      assert_response :success
      assert_template "katello/api/v2/puppet_modules/compare"

      get :compare, params: { :content_view_version_ids => [@lib_repo.content_view_version_id, @view_repo.content_view_version_id], :repository_id => @lib_repo.id }
      assert_response :success
      assert_template "katello/api/v2/puppet_modules/compare"
    end
  end
end
