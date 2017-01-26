require 'katello_test_helper'

module Katello
  class RpmTestBase < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:fedora_17_x86_64)
      @rpm_one = katello_rpms(:one)
      @rpm_two = katello_rpms(:two)
      @rpm_three = katello_rpms(:three)

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
      refute @rpm_one.nvra.blank?
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

    def test_build_nvre
      assert_equal "#{@rpm_one.name}-#{@rpm_one.version}-#{@rpm_one.release}.#{@rpm_one.arch}", @rpm_one.build_nvra
    end
  end

  class ApplicablityTest < RpmTestBase
    def setup
      super
      @host_one = katello_content_facets(:one).host
      @host_two = katello_content_facets(:two).host
    end

    def test_applicable_to_hosts
      rpms = Rpm.applicable_to_hosts([@host_one])

      assert_includes rpms, @rpm_one
      assert_includes rpms, @rpm_two
      refute_includes rpms, @rpm_three
    end

    def test_installable_for_hosts
      assert_includes @rpm_one.repositories, @repo
      @rpm_two.repositories = []
      @host_one.content_facet.bound_repositories << @repo
      rpms = Rpm.installable_for_hosts([@host_one])

      assert_equal [@rpm_one], rpms
    end

    def test_hosts_applicable
      hosts = @rpm_one.hosts_applicable(@host_one.organization_id).map(&:host)
      assert_includes hosts, @host_one
      refute_includes hosts, @host_two

      hosts = @rpm_one.hosts_applicable.map(&:host)
      assert_includes hosts, @host_one
    end

    def test_hosts_available
      @host_one.content_facet.bound_repositories += @rpm_one.repositories
      facet = @rpm_one.hosts_available(@host_one.organization_id).first
      assert_equal @host_one, facet.host
    end
  end

  class RpmImportTest < RpmTestBase
    def setup
      super
      @original_bulk_load_size = SETTINGS[:katello][:pulp][:bulk_load_size]
    end

    def random_json(count)
      count.times.map { |i| {'_id' => SecureRandom.hex, 'name' => "somename-#{i}", 'repository_memberships' => [@repo.pulp_id]} }
    end

    def test_import_all
      SETTINGS[:katello][:pulp][:bulk_load_size] = 10
      json = random_json(30)

      Katello::Pulp::Rpm.stubs(:fetch).with(0, 10).returns(json[0..10])
      Katello::Pulp::Rpm.stubs(:fetch).with(11, 10).returns(json[11..21])
      Katello::Pulp::Rpm.stubs(:fetch).with(22, 10).returns(json[21..29])
      Katello::Pulp::Rpm.stubs(:fetch).with(31, 10).returns([])
      Rpm.import_all
      assert_equal 30, @repo.reload.rpms.count
    end

    def test_import_all_uuids
      json = random_json(10)
      uuids = json.map { |obj| obj['_id'] }
      Katello::Pulp::Rpm.stubs(:fetch).with(0, 10, uuids).returns(json)

      Katello::Rpm.import_all(uuids)
      uuids_in_repo = @repo.reload.rpms.pluck(:uuid)

      uuids.each do |uuid|
        assert_includes uuids_in_repo, uuid
      end
    end

    def test_import_all_uuids_no_assoc
      json = random_json(10)
      uuids = json.map { |obj| obj['_id'] }
      Katello::Pulp::Rpm.stubs(:fetch).with(0, 10, uuids).returns(json)

      Katello::Rpm.import_all(uuids, :index_repository_association => false)
      uuids_in_repo = @repo.reload.rpms.pluck(:uuid)

      uuids.each do |uuid|
        refute_includes uuids_in_repo, uuid
      end
    end

    def teardown
      SETTINGS[:katello][:pulp][:bulk_load_size] = @original_bulk_load_size
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

      Katello::Pulp::Rpm.stubs(:ids_for_repository).returns(@packages.map { |p| p['_id'] })
      Katello::Pulp::Rpm.stubs(:fetch).returns(@packages)
      Katello::Rpm.import_for_repository(@repo)

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

      results = Rpm.in_repositories(@repo).search_version_equal("1.0.0-1.0")
      expected = ["abc123-1", "abc123-2"]
      assert_equal expected, results.map(&:uuid).sort

      results = Rpm.in_repositories(@repo).search_version_equal("1:1.0.0-1.0")
      expected = ["abc123-2"]
      assert_equal expected, results.map(&:uuid).sort
    end
  end
end
