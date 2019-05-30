require 'katello_test_helper'

module Katello
  class DockerManifestListTest < ActiveSupport::TestCase
    REPO_ID = "Default_Organization-Test-redis".freeze
    MANIFESTS = File.join(Katello::Engine.root, "test", "fixtures", "pulp", "docker_manifest_lists.yml")
    TAGS = File.join(Katello::Engine.root, "test", "fixtures", "pulp", "docker_tags.yml")

    def setup
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
      @manifest_lists = YAML.load_file(MANIFESTS).values.map(&:deep_symbolize_keys)
      @repo = Repository.find(katello_repositories(:redis).id)

      Katello::Pulp::DockerManifestList.stubs(:pulp_units_batch_for_repo).returns([@manifest_lists])
    end

    def test_import_for_repository
      Katello::DockerManifestList.import_for_repository(@repo)
      assert_equal @manifest_lists.first[:_id], @repo.docker_manifest_lists.first.pulp_id
      assert_equal @manifest_lists.first[:digest], @repo.docker_manifest_lists.first.digest
    end

    def test_search_manifest
      manifest = create(:docker_manifest_list)
      assert_includes DockerManifestList.search_for("schema_version = #{manifest.schema_version}"), manifest
      assert_includes DockerManifestList.search_for("digest = #{manifest.digest}"), manifest
    end
  end
end
