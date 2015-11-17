require "katello_test_helper"

module Katello
  class Api::V2::DockerImagesControllerTest < ActionController::TestCase
    def models
      @repo = Repository.find(katello_repositories(:redis))
      @image = @repo.docker_images.create!({:image_id => "abc123", :uuid => "123xyz"},
                                           :without_protection => true
                                          )
    end

    def setup
      setup_controller_defaults_api
      models
    end

    def test_index
      get :index, :repository_id => @repo.id
      assert_response :success
      assert_template %w(katello/api/v2/docker_images/index)

      get :index
      assert_response :success
      assert_template %w(katello/api/v2/docker_images/index)

      get :index, :organization_id => @repo.organization.id
      assert_response :success
      assert_template %w(katello/api/v2/docker_images/index)

      get :index, :content_view_version_id => ContentViewVersion.last
      assert_response :success
    end

    def test_show
      get :show, :repository_id => @repo.id, :id => @image.uuid

      assert_response :success
      assert_template %w(katello/api/v2/docker_images/show)
    end
  end
end
