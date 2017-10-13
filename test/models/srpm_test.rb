require 'katello_test_helper'

module Katello
  class SrpmTestBase < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:srpm_repo)
      @rpm_one = katello_srpms(:one)
      @rpm_two = katello_srpms(:two)
      @rpm_three = katello_srpms(:three)

      Srpm.any_instance.stubs(:backend_data).returns({})
    end
  end

  class SrpmTest < SrpmTestBase
    def test_repositories
      assert_includes @rpm_one.repository_ids, @repo.id
    end

    def test_create
      uuid = 'foo'
      assert Srpm.create!(:uuid => uuid)
      assert Srpm.find_by_uuid(uuid)
    end

    def test_with_identifiers_single
      assert_includes Srpm.with_identifiers(@rpm_one.id), @rpm_one
    end

    def test_with_multiple
      srpms = Srpm.with_identifiers([@rpm_one.id, @rpm_two.uuid])

      assert_equal 2, srpms.count
      assert_include srpms, @rpm_one
      assert_include srpms, @rpm_two
    end

    def test_update_from_json
      uuid = 'foo'
      Srpm.create!(:uuid => uuid)
      json = @rpm_one.attributes.merge('summary' => 'an update', 'version' => '3', 'release' => '4')
      @rpm_one.update_from_json(json.with_indifferent_access)
      @rpm_one = @rpm_one.reload

      assert_equal @rpm_one.summary, json['summary']
      refute @rpm_one.release_sortable.blank?
      refute @rpm_one.version_sortable.blank?
      refute @rpm_one.nvra.blank?
    end

    def test_update_from_json_is_idempotent
      last_updated = @rpm_one.updated_at
      json = @rpm_one.attributes
      @rpm_one.update_from_json(json)
      assert_equal @rpm_one.reload.updated_at, last_updated
    end

    def test_with_identifiers
      assert_includes Srpm.with_identifiers(@rpm_one.id), @rpm_one
      assert_includes Srpm.with_identifiers([@rpm_one.id]), @rpm_one
      assert_includes Srpm.with_identifiers(@rpm_one.uuid), @rpm_one
    end

    def test_build_nvre
      assert_equal "#{@rpm_one.name}-#{@rpm_one.version}-#{@rpm_one.release}.#{@rpm_one.arch}", @rpm_one.build_nvra
    end
  end

  class SrpmImportTest < SrpmTestBase
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

      Katello::Pulp::Srpm.stubs(:fetch).with(0, 10).returns(json[0..10])
      Katello::Pulp::Srpm.stubs(:fetch).with(11, 10).returns(json[11..21])
      Katello::Pulp::Srpm.stubs(:fetch).with(22, 10).returns(json[21..29])
      Katello::Pulp::Srpm.stubs(:fetch).with(31, 10).returns([])
      Srpm.import_all
      assert_equal 30, @repo.reload.srpms.count
    end

    def test_import_all_uuids
      json = random_json(10)
      uuids = json.map { |obj| obj['_id'] }
      Katello::Pulp::Srpm.stubs(:fetch).with(0, 10, uuids).returns(json)

      Katello::Srpm.import_all(uuids)
      uuids_in_repo = @repo.reload.srpms.pluck(:uuid)

      uuids.each do |uuid|
        assert_includes uuids_in_repo, uuid
      end
    end

    def test_import_all_uuids_no_assoc
      json = random_json(10)
      uuids = json.map { |obj| obj['_id'] }
      Katello::Pulp::Srpm.stubs(:fetch).with(0, 10, uuids).returns(json)

      Katello::Srpm.import_all(uuids, :index_repository_association => false)
      uuids_in_repo = @repo.reload.srpms.pluck(:uuid)

      uuids.each do |uuid|
        refute_includes uuids_in_repo, uuid
      end
    end

    def teardown
      SETTINGS[:katello][:pulp][:bulk_load_size] = @original_bulk_load_size
    end
  end

  class SrpmSortTest < ActiveSupport::TestCase
    FIXTURES_FILE = File.join(Katello::Engine.root, "test", "fixtures", "pulp", "rpms.yml")

    def setup
      @repo = katello_repositories(:fedora_17_unpublished)
      @packages = YAML.load_file(FIXTURES_FILE).values.map(&:with_indifferent_access)

      @packages.each_with_index do |package, _idx|
        package.merge!(:repoids => [@repo.pulp_id])
      end

      Katello::Pulp::Srpm.stubs(:ids_for_repository).returns(@packages.map { |p| p['_id'] })
      Katello::Pulp::Srpm.stubs(:fetch).returns(@packages)
      Katello::Srpm.import_for_repository(@repo)

      @all_ids = @repo.reload.srpms.pluck(:uuid).sort
    end
  end
end
