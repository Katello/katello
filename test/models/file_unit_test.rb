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
      uuid = 'foo'
      assert FileUnit.create!(:uuid => uuid)
      assert FileUnit.find_by_uuid(uuid)
    end

    def test_with_identifiers_single
      assert_includes FileUnit.with_identifiers(@file_one.id), @file_one
    end

    def test_with_multiple
      files = FileUnit.with_identifiers([@file_one.id, @file_two.uuid])

      assert_equal 2, files.count
      assert_include files, @file_one
      assert_include files, @file_two
    end

    def test_update_from_json
      uuid = 'foo'
      FileUnit.create!(:uuid => uuid)
      json = @file_one.attributes.merge('checksum' => '1234515')
      @file_one.update_from_json(json.with_indifferent_access)
      @file_one = FileUnit.find(@file_one)

      assert_equal @file_one.name, json['name']
    end

    def test_update_from_json_is_idempotent
      last_updated = @file_one.updated_at
      json = @file_one.attributes
      @file_one.update_from_json(json)
      assert_equal FileUnit.find(@file_one).updated_at, last_updated
    end

    def test_with_identifiers
      assert_includes FileUnit.with_identifiers(@file_one.id), @file_one
      assert_includes FileUnit.with_identifiers([@file_one.id]), @file_one
      assert_includes FileUnit.with_identifiers(@file_one.uuid), @file_one
    end
  end
end
