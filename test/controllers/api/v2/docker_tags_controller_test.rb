require "katello_test_helper"

module Katello
  class Api::V2::DockerTagsControllerTest < ActionController::TestCase
    def models
      @repo = Repository.find(katello_repositories(:redis))
      @manifest = @repo.docker_manifests.create!(:name => "abc123", :uuid => "123xyz")
      @tag = @repo.docker_tags.create!(:name => "wat", :docker_manifest => @manifest)
    end

    def setup
      setup_controller_defaults_api
      models
    end

    def test_index
      get :index, :repository_id => @repo.id
      assert_response :success
      assert_template "katello/api/v2/docker_tags/index"

      get :index
      assert_response :success
      assert_template "katello/api/v2/docker_tags/index"

      get :index, :organization_id => @repo.organization.id
      assert_response :success
      assert_template "katello/api/v2/docker_tags/index"
    end

    def test_grouped_index
      organization = @repo.organization
      repos_stub = stub(:in_organization => [@repo])
      Repository.expects(:readable).returns(repos_stub)
      get :index, :organization_id => organization.id,
        :grouped => true

      assert_response :success
      assert_template 'api/v2/docker_tags/index'

      results = JSON.parse(response.body)["results"].map { |tag| tag["name"] }
      assert_equal ['wat'], results
    end

    def test_show
      get :show, :repository_id => @repo.id, :id => @tag.id

      assert_response :success
      assert_template "katello/api/v2/docker_tags/show"
      assert_template :layout => 'katello/api/v2/layouts/resource'
    end
  end
end
