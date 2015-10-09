require "katello_test_helper"

module Katello
  class Api::V2::DockerTagsControllerTest < ActionController::TestCase
    def models
      @repo = Repository.find(katello_repositories(:redis))
      @image = @repo.docker_images.create!({:image_id => "abc123", :uuid => "123"})
      @tag = @repo.docker_tags.create!(:name => "wat", :docker_image => @image)
    end

    def setup
      setup_controller_defaults_api
      @request.env['HTTP_ACCEPT'] = 'application/json'
      @request.env['CONTENT_TYPE'] = 'application/json'
      @fake_search_service = @controller.load_search_service(Support::SearchService::FakeSearchService.new)
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

    def test_show
      get :show, :repository_id => @repo.id, :id => @tag.id

      assert_response :success
      assert_template "katello/api/v2/docker_tags/show"
      assert_template :layout => 'katello/api/v2/layouts/resource'
    end
  end
end
