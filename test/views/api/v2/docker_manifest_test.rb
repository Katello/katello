require 'katello_test_helper'

module Katello
  class DockerManifestViewTest < ActiveSupport::TestCase
    def setup
      @manifest = DockerManifest.new
    end

    def test_show
      assert_service_not_used(Pulp::DockerManifest) do
        render_rabl('katello/api/v2/docker_manifests/show.json', @manifest)
      end
    end
  end
end
