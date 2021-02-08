require 'katello_test_helper'

module Katello
  class RpmTestBase < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:fedora_17_x86_64)
      @rpm_one = katello_rpms(:one)
      @rpm_two = katello_rpms(:two)
      @rpm_three = katello_rpms(:three)
      @rpm_one_two = katello_rpms(:one_two)

      Rpm.any_instance.stubs(:backend_data).returns({})
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
    end
  end

  class RpmTest < RpmTestBase
    def test_repositories
      assert_includes @rpm_one.repository_ids, @repo.id
    end

    def test_create
      pulp_id = 'foo'
      assert Rpm.create!(:pulp_id => pulp_id)
      assert Rpm.find_by_pulp_id(pulp_id)
    end

    def test_with_identifiers_single
      assert_includes Rpm.with_identifiers(@rpm_one.id), @rpm_one
    end

    def test_with_multiple
      rpms = Rpm.with_identifiers([@rpm_one.id, @rpm_two.pulp_id])

      assert_equal 2, rpms.count
      assert_include rpms, @rpm_one
      assert_include rpms, @rpm_two
    end

    def test_in_repositories_uniqness
      repo2 = katello_repositories(:rhel_7_x86_64)
      @repo.rpms = [@rpm_one, @rpm_two]
      repo2.rpms = [@rpm_one, @rpm_two]

      assert_equal Rpm.in_repositories([@repo, repo2]).to_a.sort, [@rpm_one, @rpm_two].sort
    end

    def test_with_search
      rpms = Rpm.in_repositories(@repo).non_modular.search_for('version >= 1.0')
      expected = [@rpm_one, @rpm_one_two, @rpm_three, @rpm_two]
      assert_equal expected, rpms.to_a.sort

      rpms = Rpm.in_repositories(@repo).non_modular.search_for('version > 1.0')
      expected = [@rpm_three]
      assert_equal expected, rpms.to_a.sort

      rpms = Rpm.in_repositories(@repo).non_modular.search_for('version <= 99')
      expected = [@rpm_one, @rpm_one_two, @rpm_three, @rpm_two]
      assert_equal expected, rpms.to_a.sort

      rpms = Rpm.in_repositories(@repo).non_modular.search_for('version < 99')
      expected = [@rpm_one, @rpm_one_two, @rpm_two]
      assert_equal expected, rpms.to_a.sort

      rpms = Rpm.in_repositories(@repo).non_modular.search_for('release >= 2.el7')
      expected = [@rpm_one_two, @rpm_three]
      assert_equal expected, rpms.to_a.sort

      rpms = Rpm.in_repositories(@repo).non_modular.search_for('release > 1.el7')
      expected = [@rpm_one_two, @rpm_three]
      assert_equal expected, rpms.to_a.sort

      rpms = Rpm.in_repositories(@repo).non_modular.search_for('release <= 2.el7')
      expected = [@rpm_one, @rpm_one_two, @rpm_two]
      assert_equal expected, rpms.to_a.sort

      rpms = Rpm.in_repositories(@repo).non_modular.search_for('release < 2.el7')
      expected = [@rpm_one, @rpm_two]
      assert_equal expected, rpms.to_a.sort
    end

    def test_with_search_modular
      rpms = Rpm.in_repositories(@repo).search_for('modular = true')
      modular = katello_rpms(:modular)
      assert_includes rpms, modular
      refute_includes rpms, @rpm_one
    end

    def test_with_identifiers
      assert_includes Rpm.with_identifiers(@rpm_one.id), @rpm_one
      assert_includes Rpm.with_identifiers([@rpm_one.id]), @rpm_one
      assert_includes Rpm.with_identifiers(@rpm_one.pulp_id), @rpm_one
    end

    def test_build_nvre
      assert_equal "#{@rpm_one.name}-#{@rpm_one.version}-#{@rpm_one.release}.#{@rpm_one.arch}", @rpm_one.build_nvra
    end

    def test_copy_repository_associations
      repo_one = @repo
      repo_two = katello_repositories(:fedora_17_x86_64_dev)

      repo_one.rpms = [@rpm_one]
      repo_two.rpms = [@rpm_two]

      Katello::Rpm.copy_repository_associations(repo_one, repo_two)

      assert_equal [@rpm_one], repo_two.reload.rpms
    end

    def test_unmigrated_content
      @rpm_one.update(:migrated_pulp3_href => '/some/path')
      @rpm_two.update(:migrated_pulp3_href => nil, :missing_from_migration => false)

      refute Rpm.unmigrated_content.find_by(id: @rpm_one.id)
      assert Rpm.unmigrated_content.find_by(id: @rpm_two.id)

      @rpm_two.update(:migrated_pulp3_href => nil, :missing_from_migration => true)
      assert Rpm.unmigrated_content.find_by(id: @rpm_two.id)

      @rpm_two.update(:migrated_pulp3_href => nil, :missing_from_migration => true, :ignore_missing_from_migration => true)
      refute Rpm.unmigrated_content.find_by(id: @rpm_two.id)
    end

    def test_missing_migrated_content
      @rpm_one.update(:migrated_pulp3_href => '/some/path')
      @rpm_two.update(:migrated_pulp3_href => nil, :missing_from_migration => false)

      refute Rpm.missing_migrated_content.find_by(id: @rpm_one.id)
      refute Rpm.missing_migrated_content.find_by(id: @rpm_two.id)

      @rpm_two.update(:migrated_pulp3_href => nil, :missing_from_migration => true)
      assert Rpm.missing_migrated_content.find_by(id: @rpm_two.id)

      @rpm_two.update(:migrated_pulp3_href => nil, :missing_from_migration => true, ignore_missing_from_migration: true)
      refute Rpm.missing_migrated_content.find_by(id: @rpm_two.id)
    end

    def test_ignored_missing_migrated_content
      @rpm_one.update(:migrated_pulp3_href => '/some/path')
      @rpm_two.update(:migrated_pulp3_href => nil, :missing_from_migration => false)

      refute Rpm.ignored_missing_migrated_content.find_by(id: @rpm_one.id)
      refute Rpm.ignored_missing_migrated_content.find_by(id: @rpm_two.id)

      @rpm_two.update(:migrated_pulp3_href => nil, :missing_from_migration => true)
      refute Rpm.ignored_missing_migrated_content.find_by(id: @rpm_two.id)

      @rpm_two.update(:migrated_pulp3_href => nil, :missing_from_migration => true, ignore_missing_from_migration: true)
      assert Rpm.ignored_missing_migrated_content.find_by(id: @rpm_two.id)
    end
  end

  class ApplicablityTest < RpmTestBase
    def setup
      super
      @host_one = katello_content_facets(:content_facet_one).host
      @host_two = katello_content_facets(:content_facet_two).host
    end

    def teardown
      rpm = Rpm.where(nvra: "one-1.0-2.el7.x86_64").first
      rpm.update(epoch: '0')
      rpm.update(version: '1.0')
      rpm.update(release: '2.el7')
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

    def test_epoch_updates_evr_string
      rpm = Rpm.where(nvra: "one-1.0-2.el7.x86_64").first
      installed_package = InstalledPackage.create(name: rpm.name, nvra: rpm.nvra, epoch: rpm.epoch, version: rpm.version, release: rpm.release, arch: rpm.arch, :nvrea => rpm.nvrea)
      rpm.update(epoch: '99')
      installed_package.update(epoch: '99')
      rpm.reload
      installed_package.reload

      assert_equal "(99,\"{\"\"(1,)\"\",\"\"(0,)\"\"}\",\"{\"\"(2,)\"\",\"\"(0,el)\"\",\"\"(7,)\"\"}\")", rpm.evr
      assert_equal "(99,\"{\"\"(1,)\"\",\"\"(0,)\"\"}\",\"{\"\"(2,)\"\",\"\"(0,el)\"\",\"\"(7,)\"\"}\")", installed_package.evr
    end

    def test_version_updates_evr_string
      rpm = Rpm.where(nvra: "one-1.0-2.el7.x86_64").first
      installed_package = InstalledPackage.create(name: rpm.name, nvra: rpm.nvra, epoch: rpm.epoch, version: rpm.version, release: rpm.release, arch: rpm.arch, :nvrea => rpm.nvrea)
      rpm.update(version: '2.0')
      installed_package.update(version: '2.0')
      rpm.reload
      installed_package.reload

      assert_equal "(0,\"{\"\"(2,)\"\",\"\"(0,)\"\"}\",\"{\"\"(2,)\"\",\"\"(0,el)\"\",\"\"(7,)\"\"}\")", rpm.evr
      assert_equal "(0,\"{\"\"(2,)\"\",\"\"(0,)\"\"}\",\"{\"\"(2,)\"\",\"\"(0,el)\"\",\"\"(7,)\"\"}\")", installed_package.evr
    end

    def test_release_updates_evr_string
      rpm = Rpm.where(nvra: "one-1.0-2.el7.x86_64").first
      installed_package = InstalledPackage.create(name: rpm.name, nvra: rpm.nvra, epoch: rpm.epoch, version: rpm.version, release: rpm.release, arch: rpm.arch, :nvrea => rpm.nvrea)
      rpm.update(release: '3.el8')
      installed_package.update(release: '3.el8')
      rpm.reload
      installed_package.reload

      assert_equal "(0,\"{\"\"(1,)\"\",\"\"(0,)\"\"}\",\"{\"\"(3,)\"\",\"\"(0,el)\"\",\"\"(8,)\"\"}\")", rpm.evr
      assert_equal "(0,\"{\"\"(1,)\"\",\"\"(0,)\"\"}\",\"{\"\"(3,)\"\",\"\"(0,el)\"\",\"\"(8,)\"\"}\")", installed_package.evr
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
      count = Katello::Rpm.all.count
      Katello::Pulp::Rpm.stubs(:pulp_units_batch_all).returns([json[0..29]])
      Katello::Rpm.import_all
      assert_equal 30, Katello::Rpm.all.count - count
    end

    def test_import_all_pulp_ids
      json = random_json(10)
      pulp_ids = json.map { |obj| obj['_id'] }
      Katello::Pulp::Rpm.stubs(:pulp_units_batch_all).with(pulp_ids).returns([json])

      Katello::Rpm.import_all(pulp_ids)
      # We don't create repo associations anymore
      pulp_ids_imported = Katello::Rpm.all.pluck(:pulp_id)

      pulp_ids.each do |pulp_id|
        assert_includes pulp_ids_imported, pulp_id
      end
    end

    def test_import_all_pulp_ids_no_assoc
      json = random_json(10)
      pulp_ids = json.map { |obj| obj['_id'] }
      Katello::Pulp::Rpm.stubs(:pulp_units_batch_all).with(pulp_ids).returns([json])

      Katello::Rpm.import_all(pulp_ids)
      pulp_ids_in_repo = @repo.reload.rpms.pluck(:pulp_id)

      pulp_ids.each do |pulp_id|
        refute_includes pulp_ids_in_repo, pulp_id
      end
    end

    def test_import_all_removes_duplicates
      json = random_json(1)
      pulp_ids = json.map { |obj| obj['_id'] }
      json.first["name"] = @rpm_one.name
      json.first["version"] = @rpm_one.version
      json.first["release"] = @rpm_one.release
      json.first["epoch"] = @rpm_one.epoch
      json.first["arch"] = @rpm_one.arch
      Katello::Pulp::Rpm.stubs(:pulp_units_batch_all).with(pulp_ids).returns([json])
      refute_nil ::Katello::RepositoryRpm.find_by(rpm_id: @rpm_one.id, repository_id: @repo.id)
      Katello::Rpm.import_all(pulp_ids, @repo)
      assert_nil ::Katello::RepositoryRpm.find_by(rpm_id: @rpm_one.id, repository_id: @repo.id)
    end

    def teardown
      SETTINGS[:katello][:pulp][:bulk_load_size] = @original_bulk_load_size
    end
  end

  class RpmSortTest < ActiveSupport::TestCase
    FIXTURES_FILE = File.join(Katello::Engine.root, "test", "fixtures", "pulp", "rpms.yml")

    def setup
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
      @repo = katello_repositories(:fedora_17_unpublished)
      @packages = YAML.load_file(FIXTURES_FILE).values.map(&:with_indifferent_access)

      @packages.each_with_index do |package, _idx|
        package.merge!(:repoids => [@repo.pulp_id])
      end

      Katello::Pulp::Rpm.stubs(:pulp_units_batch_for_repo).returns([@packages])
      Katello::Rpm.import_for_repository(@repo)

      @all_ids = @repo.reload.rpms.pluck(:pulp_id).sort
    end

    def test_no_version_filter
      results = Rpm.in_repositories(@repo).search_version_range.all
      assert_equal @all_ids, results.map(&:pulp_id).sort
    end

    def test_min_version_filter
      results = Rpm.in_repositories(@repo).search_version_range("1.0.0")
      assert_equal ["abc123-2", "abc123-4", "abc123-6"], results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_version_range("1.0.0", '')
      assert_equal ["abc123-2", "abc123-4", "abc123-6"], results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_version_range("1")
      expected = @all_ids - ["abc123-8"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_version_range("1.0.0-1.0")
      expected = ["abc123-2", "abc123-4", "abc123-6"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_version_range("1.0.0-1el4")
      expected = ["abc123-1", "abc123-2", "abc123-4", "abc123-5", "abc123-6"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_version_range("0:")
      expected = ["abc123-2"]
      assert_equal expected, results.map(&:pulp_id).sort
    end

    def test_max_version_filter
      results = Rpm.in_repositories(@repo).search_version_range(nil, "1:1.0.0")
      assert_equal @all_ids - ["abc123-2"], results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_version_range('', "1:1.0.0")
      assert_equal @all_ids - ["abc123-2"], results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_version_range(nil, "0:1.0.0")
      assert_equal ["abc123-8"], results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_version_range(nil, "1:")
      expected = @all_ids - ["abc123-2"]
      assert_equal expected, results.map(&:pulp_id).sort
    end

    def test_version_range_filter
      results = Rpm.in_repositories(@repo).search_version_range("0.9.1", "2:0.9.1")
      assert_equal @all_ids, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_version_range("1.0.0", "1.0.0-0.9.1")
      assert_empty results

      results = Rpm.in_repositories(@repo).search_version_range("1.0.0-1", "1.0.0-1.2")
      expected = ["abc123-1", "abc123-5"]
      assert_equal expected, results.map(&:pulp_id).sort
    end

    def test_equal_filter
      results = Rpm.in_repositories(@repo).search_version_equal("1.0.0")
      expected = @all_ids - ["abc123-2", "abc123-4", "abc123-6", "abc123-8"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_version_equal("1:1.0.0")
      expected = ["abc123-2"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_version_equal("1.0.0-1.0")
      expected = ["abc123-1"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_version_equal("1:1.0.0-1.0")
      expected = ["abc123-2"]
      assert_equal expected, results.map(&:pulp_id).sort
    end

    def test_search_equal
      results = Rpm.in_repositories(@repo).search_for("evr != 1.0.0")
      expected = ["abc123-2", "abc123-4", "abc123-6", "abc123-8"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr = 1.0.0")
      expected = @all_ids - expected
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr = 1:1.0.0")
      expected = ["abc123-2"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr != 1:1.0.0")
      expected = @all_ids - expected
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr = 1.0.0-1.0")
      expected = ["abc123-1"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr != 1.0.0-1.0")
      expected = @all_ids - expected
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr = 1:1.0.0-1.0")
      expected = ["abc123-2"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr != 1:1.0.0-1.0")
      expected = @all_ids - expected
      assert_equal expected, results.map(&:pulp_id).sort
    end

    def test_search_in
      results = Rpm.in_repositories(@repo).search_for("evr ^ (1.0.0-1el5,1:1.0.0-1.0)")
      expected = ["abc123-2", "abc123-5"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr !^ (1.0.0-1el5,1:1.0.0-1.0)")
      expected = @all_ids - expected
      assert_equal expected, results.map(&:pulp_id).sort
    end

    def test_search_compare_gt_lte
      results = Rpm.in_repositories(@repo).search_for("evr > 1.0.0")
      expected = ["abc123-2", "abc123-4", "abc123-6"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr <= 1.0.0")
      expected = @all_ids - expected
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr > 1")
      expected = @all_ids - ["abc123-8"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr <= 1")
      expected = @all_ids - expected
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr > 1.0.0-1.0")
      expected = ["abc123-2", "abc123-4", "abc123-6"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr <= 1.0.0-1.0")
      expected = @all_ids - expected
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr > 1.0.0-1el4")
      expected = ["abc123-1", "abc123-2", "abc123-4", "abc123-5", "abc123-6"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr <= 1.0.0-1el4")
      expected = @all_ids - expected
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr > 0:")
      expected = ["abc123-2"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr <= 0:")
      expected = @all_ids - expected
      assert_equal expected, results.map(&:pulp_id).sort
    end

    def test_search_compare_lt_gte
      results = Rpm.in_repositories(@repo).search_for("evr < 1:1.0.0")
      expected = @all_ids - ["abc123-2"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr >= 1:1.0.0")
      expected = @all_ids - expected
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr < 0:1.0.0")
      expected = ["abc123-8"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr >= 0:1.0.0")
      expected = @all_ids - expected
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr >= 1:")
      expected = ["abc123-2"]
      assert_equal expected, results.map(&:pulp_id).sort

      results = Rpm.in_repositories(@repo).search_for("evr < 1:")
      expected = @all_ids - expected
      assert_equal expected, results.map(&:pulp_id).sort
    end

    def test_search_like
      # Disabled until https://github.com/wvanbergen/scoped_search/pull/178 is merged
      #results = Rpm.in_repositories(@repo).search_for("evr ~ :1.0.0-1")
      #expected = ["abc123-1", "abc123-2", "abc123-5"]
      #assert_equal expected, results.map(&:pulp_id).sort

      #results = Rpm.in_repositories(@repo).search_for("evr !~ :1.0.0-1")
      #expected = @all_ids - ["abc123-2"]
      #assert_equal expected, results.map(&:pulp_id).sort
    end
  end
end
