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

  class ContentIndexMaintenanceTest < ActiveSupport::TestCase
    def setup
      @content_type = RepositoryTypeManager.find_content_type('rpm')
      @repo = katello_repositories(:fedora_17_x86_64)
      @other_repo = katello_repositories(:fedora_17_x86_64_dev)
      @rpm_one = katello_rpms(:one)
      @rpm_two = katello_rpms(:two)
      @version_href = '/pulp/api/v3/repositories/rpm/rpm/maintenance/versions/1/'
      @repo.update_columns(:version_href => @version_href)
      @other_repo.update_columns(:version_href => @version_href)
      RepositoryRpm.where(:repository_id => @repo.id).delete_all
      RepositoryRpm.create!(:repository_id => @repo.id, :rpm_id => @rpm_one.id)
      RepositoryRpm.create!(:repository_id => @repo.id, :rpm_id => @rpm_two.id)
    end

    def indexer
      ContentUnitIndexer.new(:content_type => @content_type, :repository => @repo)
    end

    def tracker(unit_ids)
      tracker = mock('association_tracker')
      tracker.stubs(:unit_ids).returns(unit_ids)
      tracker.stubs(:content_index_values).returns([])
      tracker
    end

    def indexed_rpm_ids
      index = ContentIndex.find_by(:version_href => @version_href)
      ContentIndexRpm.where(:content_index_id => index.id).pluck(:rpm_id).sort
    end

    def test_a_delta_pass_materialises_the_index_from_the_repository_rows
      indexer.send(:sync_content_index, tracker([@rpm_two.id]), true)

      assert_equal [@rpm_one.id, @rpm_two.id].sort, indexed_rpm_ids
      assert_nil @repo.reload.content_index_id
    end

    def test_the_pointer_is_published_after_the_pass
      indexer.send(:sync_content_index, tracker([@rpm_two.id]), true)
      @repo.publish_content_index_pointer

      assert_equal ContentIndex.find_by(:version_href => @version_href).id, @repo.reload.content_index_id
    end

    def test_the_pointer_moves_to_the_index_of_the_current_version
      old_index = ContentIndex.create!(:version_href => '/pulp/api/v3/repositories/rpm/rpm/old/versions/1/')
      new_index = ContentIndex.create!(:version_href => @version_href)
      @repo.update_columns(:content_index_id => old_index.id)

      @repo.publish_content_index_pointer

      assert_equal new_index.id, @repo.reload.content_index_id
    end

    def test_a_private_pointer_is_cleared_before_a_reindex
      index = ContentIndex.create!(:version_href => @version_href)
      @repo.update_columns(:content_index_id => index.id)

      @repo.prepare_content_index_pointer

      assert_nil @repo.reload.content_index_id
    end

    def test_a_shared_pointer_survives_a_reindex
      index = ContentIndex.create!(:version_href => @version_href)
      @repo.update_columns(:content_index_id => index.id)
      @other_repo.update_columns(:content_index_id => index.id)

      @repo.prepare_content_index_pointer

      assert_equal index.id, @repo.reload.content_index_id
    end

    def test_an_empty_pass_prunes_a_private_index
      indexer.send(:sync_content_index, tracker([@rpm_one.id, @rpm_two.id]), false)

      empty = mock('association_tracker')
      empty.stubs(:unit_ids).returns([])
      empty.stubs(:db_values).returns([])
      empty.stubs(:content_index_values).returns([])

      indexer.send(:sync_repository_associations, empty, :additive => false)

      assert_empty indexed_rpm_ids
    end

    def test_a_full_pass_prunes_a_private_index
      indexer.send(:sync_content_index, tracker([@rpm_one.id]), false)

      assert_equal [@rpm_one.id], indexed_rpm_ids
    end

    def test_a_full_pass_leaves_a_shared_index_alone
      indexer.send(:sync_content_index, tracker([@rpm_one.id]), true)
      @other_repo.update_columns(:content_index_id => ContentIndex.find_by(:version_href => @version_href).id)

      indexer.send(:sync_content_index, tracker([@rpm_one.id]), false)

      assert_equal [@rpm_one.id, @rpm_two.id].sort, indexed_rpm_ids
    end

    def test_a_shared_index_is_not_materialised_by_another_repository
      index = ContentIndex.create!(:version_href => @version_href)
      @other_repo.update_columns(:content_index_id => index.id)

      indexer.send(:sync_content_index, tracker([@rpm_one.id]), true)

      assert_empty ContentIndexRpm.where(:content_index_id => index.id)
    end

    def test_a_filtered_pass_after_a_version_change_drops_the_stale_pointer
      old_index = ContentIndex.create!(:version_href => '/pulp/api/v3/repositories/rpm/rpm/old/versions/1/')
      ContentIndexRpm.create!(:content_index_id => old_index.id, :rpm_id => @rpm_one.id)
      @repo.update_columns(:content_index_id => old_index.id)

      indexer.send(:sync_content_index, tracker([@rpm_two.id]), true)

      assert_nil @repo.reload.content_index_id
      assert_equal [@rpm_one.id], ContentIndexRpm.where(:content_index_id => old_index.id).pluck(:rpm_id)
    end

    def test_a_stale_pointer_does_not_let_an_upload_edit_the_old_index
      old_index = ContentIndex.create!(:version_href => '/pulp/api/v3/repositories/rpm/rpm/old/versions/1/')
      ContentIndexRpm.create!(:content_index_id => old_index.id, :rpm_id => @rpm_one.id)
      @repo.update_columns(:content_index_id => old_index.id)

      indexer.send(:remove_index_duplicates, [@rpm_one.id])

      assert_equal [@rpm_one.id], ContentIndexRpm.where(:content_index_id => old_index.id).pluck(:rpm_id)
    end
  end
end
