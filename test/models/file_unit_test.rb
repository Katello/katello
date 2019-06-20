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

    def test_bad_query
      assert_empty FileUnit.where(:pulp_id => ['']*70000)
    end

  end
end
