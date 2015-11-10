require "katello_test_helper"

module Katello
  class Api::V2::DockerTagsControllerTest < ActionController::TestCase
    def models
      @repo = Repository.find(katello_repositories(:redis))
      @image = @repo.docker_images.create!({:image_id => "abc123", :uuid => "123"},
                                           :without_protection => true
                                          )
      @tag = @repo.docker_tags.create!(:name => "wat", :docker_image => @image)
    end

    def setup
      setup_controller_defaults_api
      models
    end

    def test_index
      get :index, :repository_id => @repo.id
      assert_response :success
      assert_template %w(katello/api/v2/docker_tags/index)

      get :index
      assert_response :success
      assert_template %w(katello/api/v2/docker_tags/index)

      get :index, :organization_id => @repo.organization.id
      assert_response :success
      assert_template %w(katello/api/v2/docker_tags/index)
    end

    def test_show
      get :show, :repository_id => @repo.id, :id => @tag.id

      assert_response :success
      assert_template %w(katello/api/v2/errata/show)
    end
  end
end
