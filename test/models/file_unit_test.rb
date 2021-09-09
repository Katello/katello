require 'katello_test_helper'

module Katello
  class FileUnitTestBase < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:generic_file)
      @file_one = katello_files(:one)
      @file_two = katello_files(:two)
      FileUnit.any_instance.stubs(:backend_data).returns({})
    end
  end

  class FileUnitTest < FileUnitTestBase
    def test_repositories
      assert_includes @file_one.repository_ids, @repo.id
    end

    def test_create
      pulp_id = 'foo'
      assert FileUnit.create!(:pulp_id => pulp_id)
      assert FileUnit.find_by_pulp_id(pulp_id)
    end

    def test_with_identifiers_single
      assert_includes FileUnit.with_identifiers(@file_one.id), @file_one
    end

    def test_with_multiple
      files = FileUnit.with_identifiers([@file_one.id, @file_two.pulp_id])

      assert_equal 2, files.count
      assert_include files, @file_one
      assert_include files, @file_two
    end

    def test_with_identifiers
      assert_includes FileUnit.with_identifiers(@file_one.id), @file_one
      assert_includes FileUnit.with_identifiers([@file_one.id]), @file_one
      assert_includes FileUnit.with_identifiers(@file_one.pulp_id), @file_one
    end

    def test_large_query
      ids = ['href'] * 70_000 + [@file_one.pulp_id]
      assert_equal 1, FileUnit.with_pulp_id(ids).count
    end

    def test_large_sync_repository_association
      i, ids, ids_href_map = 0, [], {}
      while (i < 70_000)
        ids[i] = ["href#{i}"]
        ids_href_map["href#{i}"] = nil
        i += 1
      end
      Katello::FileUnit.import([:pulp_id], ids, validate: false)

      content_type = Katello::RepositoryTypeManager.find_content_type('file')
      service_class = content_type.pulp3_service_class

      indexer = Katello::ContentUnitIndexer.new(content_type: content_type, repository: @repo)
      tracker = Katello::ContentUnitIndexer::RepoAssociationTracker.new(content_type, service_class, @repo)
      ids_href_map.keys.each do |href|
        tracker.push({pulp_href: href}.with_indifferent_access)
      end
      indexer.sync_repository_associations(tracker)

      file_unit_size_post = @repo.file_units.size
      assert_equal file_unit_size_post, 70_000
    end
  end
end
