require "katello_test_helper"

module Katello
  class Api::V2::DockerManifestListsControllerTest < ActionController::TestCase
    def models
      @repo = Repository.find(katello_repositories(:redis).id)
      @manifest_list = @repo.docker_manifest_lists.create!(:digest => "aeeeeeebc123", :uuid => "123xyz")
    end

    def setup
      setup_controller_defaults_api
      models
    end

    def test_index
      get :index
      assert_response :success
      assert_template "katello/api/v2/docker_manifest_lists/index"
    end

    def test_index_with_repository
      get :index, params: { :repository_id => @repo.id }
      assert_response :success
      assert_template "katello/api/v2/docker_manifest_lists/index"
    end

    def test_index_with_organization
      get :index, params: { :organization_id => @repo.organization.id }
      assert_response :success
      assert_template "katello/api/v2/docker_manifest_lists/index"
    end

    def test_index_with_content_view_version
      get :index, params: { :content_view_version_id => ContentViewVersion.last }
      assert_response :success
      assert_template "katello/api/v2/docker_manifest_lists/index"
    end

    def test_show
      get :show, params: { :repository_id => @repo.id, :id => @manifest_list.uuid }

      assert_response :success
      assert_template "katello/api/v2/docker_manifest_lists/show"
    end
  end
end
