require 'katello_test_helper'

module Katello
  class RpmTestBase < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:fedora_17_x86_64)
      @rpm_one = katello_rpms(:one)
      @rpm_two = katello_rpms(:two)
      Rpm.any_instance.stubs(:backend_data).returns({})
    end
  end

  class RpmTest < RpmTestBase
    def test_repositories
      assert_includes @rpm_one.repository_ids, @repo.id
    end

    def test_create
      uuid = 'foo'
      assert Rpm.create!(:uuid => uuid)
      assert Rpm.find_by_uuid(uuid)
    end

    def test_with_identifiers_single
      assert_includes Rpm.with_identifiers(@rpm_one.id), @rpm_one
    end

    def test_with_multiple
      rpms = Rpm.with_identifiers([@rpm_one.id, @rpm_two.uuid])

      assert_equal 2, rpms.count
      assert_include rpms, @rpm_one
      assert_include rpms, @rpm_two
    end

    def test_update_from_json
      uuid = 'foo'
      Rpm.create!(:uuid => uuid)
      json = @rpm_one.attributes.merge('summary' => 'an update', 'version' => '3', 'release' => '4')
      @rpm_one.update_from_json(json.with_indifferent_access)
      @rpm_one = Rpm.find(@rpm_one)

      assert_equal @rpm_one.summary, json['summary']
      refute @rpm_one.release_sortable.blank?
      refute @rpm_one.version_sortable.blank?
    end

    def test_update_from_json_is_idempotent
      last_updated = @rpm_one.updated_at
      json = @rpm_one.attributes
      @rpm_one.update_from_json(json)
      assert_equal Rpm.find(@rpm_one).updated_at, last_updated
    end

    def test_with_identifiers
      assert_includes Rpm.with_identifiers(@rpm_one.id), @rpm_one
      assert_includes Rpm.with_identifiers([@rpm_one.id]), @rpm_one
      assert_includes Rpm.with_identifiers(@rpm_one.uuid), @rpm_one
    end
  end

  class RpmSortTest < ActiveSupport::TestCase
    FIXTURES_FILE = File.join(Katello::Engine.root, "test", "fixtures", "pulp", "rpms.yml")

    def setup
      @repo = katello_repositories(:fedora_17_unpublished)
      @packages = YAML.load_file(FIXTURES_FILE).values.map(&:with_indifferent_access)

      @packages.each_with_index do |package, _idx|
        package.merge!(:repoids => [@repo.pulp_id])
      end

      @repo.stubs(:rpms_json).returns(@packages)
      @repo.stubs(:pulp_rpm_ids).returns(@packages.map { |p| p['_id'] })
      @repo.index_db_rpms
      @all_ids = @repo.rpms.pluck(:uuid).sort
    end

    def test_no_version_filter
      results = Rpm.in_repositories(@repo).search_version_range.all
      assert_equal @all_ids, results.map(&:uuid).sort
    end

    def test_min_version_filter
      results = Rpm.in_repositories(@repo).search_version_range("1.0.0")
      assert_equal ["abc123-4", "abc123-6"], results.map(&:uuid).sort

      results = Rpm.in_repositories(@repo).search_version_range("1")
      expected = @all_ids - ["abc123-8"]
      assert_equal expected, results.map(&:uuid).sort

      results = Rpm.in_repositories(@repo).search_version_range("1.0.0-1.0")
      expected = ["abc123-4", "abc123-6"]
      assert_equal expected, results.map(&:uuid).sort

      results = Rpm.in_repositories(@repo).search_version_range("1.0.0-1el4")
      expected = ["abc123-1", "abc123-2", "abc123-4", "abc123-5", "abc123-6"]
      assert_equal expected, results.map(&:uuid).sort
    end

    def test_max_version_filter
      results = Rpm.in_repositories(@repo).search_version_range(nil, "1:1.0.0")
      assert_equal @all_ids - ["abc123-2"], results.map(&:uuid).sort

      results = Rpm.in_repositories(@repo).search_version_range(nil, "0:1.0.0")
      assert_equal ["abc123-8"], results.map(&:uuid).sort
    end

    def test_version_range_filter
      results = Rpm.in_repositories(@repo).search_version_range("0.9.1", "2:0.9.1")
      assert_equal @all_ids, results.map(&:uuid).sort

      results = Rpm.in_repositories(@repo).search_version_range("1.0.0", "1.0.0-0.9.1")
      assert_empty results

      results = Rpm.in_repositories(@repo).search_version_range("1.0.0-1", "1.0.0-1.2")
      expected = ["abc123-1", "abc123-2", "abc123-5"]
      assert_equal expected, results.map(&:uuid).sort
    end

    def test_equal_filter
      results = Rpm.in_repositories(@repo).search_version_equal("1.0.0")
      expected = @all_ids - ["abc123-4", "abc123-6", "abc123-8"]
      assert_equal expected, results.map(&:uuid).sort

      results = Rpm.in_repositories(@repo).search_version_equal("1:1.0.0")
      expected = ["abc123-2"]
      assert_equal expected, results.map(&:uuid).sort

      results = Rpm.in_repositories(@repo).search_version_equal("1:1.0.0-1.0")
      expected = ["abc123-2"]
      assert_equal expected, results.map(&:uuid).sort
    end
  end
end
