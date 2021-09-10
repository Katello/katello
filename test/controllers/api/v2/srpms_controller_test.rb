require "katello_test_helper"

module Katello
  class Api::V2::SrpmsControllerTest < ActionController::TestCase
    def models
      @repo = katello_repositories(:srpm_repo)
      @srpm = katello_srpms(:one)
      @version = katello_content_view_versions(:library_view_version_1)
      @organization = get_organization
    end

    def setup
      setup_controller_defaults_api
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      models
      setup_product_permissions
    end

    def test_index
      get :index, params: { :repository_id => @repo.id }

      assert_response :success
      assert_template "katello/api/v2/srpms/index"
    end

    def test_index_with_environment_id
      environment = KTEnvironment.first
      KTEnvironment.expects(:readable).returns(stub(:find_by => environment))

      get :index, params: { :environment_id => environment.id }

      assert_response :success
      assert_template "katello/api/v2/srpms/index"
    end

    def test_index_with_org_id
      get :index, params: { :organization_id => @organization.id }

      assert_response :success
      assert_template "katello/api/v2/srpms/index"
    end

    def test_index_parameters
      get :index

      assert_response :success
    end

    def test_index_with_available_for_content_view_version
      response = get :index, params: { :content_view_version_id => @version.id, :available_for => 'content_view_version' }

      assert_response :success
      ids = JSON.parse(response.body)['results'].map { |p| p['id'] }
      assert_includes ids, @srpm.id
    end

    def test_index_protected
      assert_protected_action(:index, @auth_permissions, @unauth_permissions) do
        get :index, params: { :repository_id => @repo.id }
      end
    end

    def test_compare
      get :compare, params: { :content_view_version_ids => [@repo.content_view_version_id, @repo.content_view_version_id] }
      assert_response :success
      assert_template "katello/api/v2/srpms/compare"
    end
  end
end
