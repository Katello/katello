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
      pulp_id = 'foo'
      assert Srpm.create!(:pulp_id => pulp_id)
      assert Srpm.find_by_pulp_id(pulp_id)
    end

    def test_with_identifiers_single
      assert_includes Srpm.with_identifiers(@rpm_one.id), @rpm_one
    end

    def test_with_multiple
      srpms = Srpm.with_identifiers([@rpm_one.id, @rpm_two.pulp_id])

      assert_equal 2, srpms.count
      assert_include srpms, @rpm_one
      assert_include srpms, @rpm_two
    end

    def test_with_identifiers
      assert_includes Srpm.with_identifiers(@rpm_one.id), @rpm_one
      assert_includes Srpm.with_identifiers([@rpm_one.id]), @rpm_one
      assert_includes Srpm.with_identifiers(@rpm_one.pulp_id), @rpm_one
    end

    def test_build_nvre
      assert_equal "#{@rpm_one.name}-#{@rpm_one.version}-#{@rpm_one.release}.#{@rpm_one.arch}", @rpm_one.build_nvra
    end
  end

  class SrpmImportTest < SrpmTestBase
    def setup
      super
      @original_bulk_load_size = Setting[:bulk_load_size]
    end

    def random_json(count)
      count.times.map { |i| {'pulp_href' => SecureRandom.hex, 'name' => "somename-#{i}", 'repository_memberships' => [@repo.pulp_id]} }
    end

    def test_import_all_pulp_ids
      json = random_json(10)
      pulp_ids = json.map { |obj| obj['pulp_href'] }
      Katello::Pulp3::Srpm.stubs(:pulp_units_batch_all).with(pulp_ids).returns([json])

      Katello::Srpm.import_all(pulp_ids)
      pulp_ids_imported = Katello::Srpm.all.pluck(:pulp_id)

      pulp_ids.each do |pulp_id|
        assert_includes pulp_ids_imported, pulp_id
      end
    end

    def test_import_all_pulp_ids_no_assoc
      json = random_json(10)
      pulp_ids = json.map { |obj| obj['pulp_href'] }
      Katello::Pulp3::Srpm.stubs(:pulp_units_batch_all).with(pulp_ids).returns([json])

      Katello::Srpm.import_all(pulp_ids)
      pulp_ids_in_repo = @repo.reload.srpms.pluck(:pulp_id)
      pulp_ids_imported = Katello::Srpm.all.pluck(:pulp_id)

      pulp_ids.each do |pulp_id|
        refute_includes pulp_ids_in_repo, pulp_id
        assert_includes pulp_ids_imported, pulp_id
      end
    end

    def teardown
      ::Setting[:bulk_load_size] = @original_bulk_load_size
    end
  end

  class SrpmSortTest < ActiveSupport::TestCase
    FIXTURES_FILE = File.join(Katello::Engine.root, "test", "fixtures", "pulp3", "rpms.yml")

    def setup
      @repo = katello_repositories(:fedora_17_unpublished)
      @packages = YAML.load_file(FIXTURES_FILE).values.map(&:with_indifferent_access)

      @packages.each_with_index do |package, _idx|
        package.merge!(:repoids => [@repo.pulp_id])
      end

      Katello::Pulp3::Srpm.stubs(:pulp_units_batch_all).returns([@packages])
      Katello::Srpm.import_for_repository(@repo)

      @all_ids = @repo.reload.srpms.pluck(:pulp_id).sort
    end
  end
end
