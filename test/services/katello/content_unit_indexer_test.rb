require 'katello_test_helper'

module Katello
  class ContentUnitIndexerTest < ActiveSupport::TestCase
    # rubocop:disable Metrics/AbcSize
    def test_clean_duplicate_docker_tags
      @repo = katello_repositories(:fedora_17_x86_64_dev)
      content_type = Katello::RepositoryTypeManager.find_content_type('docker_tag')
      indexer = Katello::ContentUnitIndexer.new(content_type: content_type, repository: @repo)
      base_time = 3.hours.ago

      manifest_a = @repo.docker_manifests.create!(
        digest: "sha256:aaaa1111",
        pulp_id: "manifest_a_pulp_id",
        schema_version: 2
      )
      manifest_b = @repo.docker_manifests.create!(
        digest: "sha256:bbbb2222",
        pulp_id: "manifest_b_pulp_id",
        schema_version: 2
      )
      manifest_c = @repo.docker_manifests.create!(
        digest: "sha256:cccc3333",
        pulp_id: "manifest_c_pulp_id",
        schema_version: 2
      )
      @repo.docker_tags.create!(
        name: "foo",
        docker_taggable: manifest_a,
        pulp_id: "tag_a_foo_pulp_id",
        updated_at: base_time + 1.hour
      )
      tag_a_bar = @repo.docker_tags.create!(
        name: "bar",
        docker_taggable: manifest_a,
        pulp_id: "tag_a_bar_pulp_id",
        updated_at: base_time + 3.hours
      )
      tag_a_baz = @repo.docker_tags.create!(
        name: "baz",
        docker_taggable: manifest_a,
        pulp_id: "tag_a_baz_pulp_id",
        updated_at: base_time + 1.hour
      )
      @repo.docker_tags.create!(
        name: "foo",
        docker_taggable: manifest_b,
        pulp_id: "tag_b_foo_pulp_id",
        updated_at: base_time + 2.hours
      )
      @repo.docker_tags.create!(
        name: "bar",
        docker_taggable: manifest_b,
        pulp_id: "tag_b_bar_pulp_id",
        updated_at: base_time + 2.hours
      )
      tag_c_foo = @repo.docker_tags.create!(
        name: "foo",
        docker_taggable: manifest_c,
        pulp_id: "tag_c_foo_pulp_id",
        updated_at: base_time + 4.hours
      )

      indexer.send(:clean_duplicate_docker_tags)
      remaining_tags = @repo.docker_tags.reload

      # Manifest A should have 'bar' and 'baz' remaining
      manifest_a_tags = remaining_tags.where(docker_taggable: manifest_a)
      assert_equal 2, manifest_a_tags.count
      assert_includes manifest_a_tags.pluck(:name), "bar"
      assert_includes manifest_a_tags.pluck(:name), "baz"
      assert_equal tag_a_bar.id, manifest_a_tags.find_by(name: "bar").id
      assert_equal tag_a_baz.id, manifest_a_tags.find_by(name: "baz").id

      # Manifest B should have no tags
      manifest_b_tags = remaining_tags.where(docker_taggable: manifest_b)
      assert_equal 0, manifest_b_tags.count

      # Manifest C should have 'foo'
      manifest_c_tags = remaining_tags.where(docker_taggable: manifest_c)
      assert_equal 1, manifest_c_tags.count
      assert_equal "foo", manifest_c_tags.first.name
      assert_equal tag_c_foo.id, manifest_c_tags.first.id

      assert_equal 3, remaining_tags.count
      assert_equal 1, remaining_tags.where(name: "foo").count  # only C's foo
      assert_equal 1, remaining_tags.where(name: "bar").count  # only A's bar
      assert_equal 1, remaining_tags.where(name: "baz").count  # only A's baz
    end
    # rubocop:enable Metrics/AbcSize
  end
end
