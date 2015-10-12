require 'katello_test_helper'

module Katello
  class DockerImageViewTest < ActiveSupport::TestCase
    def setup
      @image = DockerImage.new
    end

    def test_show
      assert_service_not_used(Pulp::DockerImage) do
        render_rabl('katello/api/v2/docker_images/show.json', @image)
      end
    end
  end
end
