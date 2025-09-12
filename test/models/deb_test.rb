require 'katello_test_helper'

module Katello
  class DebTestBase < ActiveSupport::TestCase
    def setup
      @repo = katello_repositories(:debian_10_amd64)
      @deb_one = katello_debs(:one)
      @deb_two = katello_debs(:two)
      @deb_three = katello_debs(:three)
      @deb_one_v2 = katello_debs(:one_new)

      Deb.any_instance.stubs(:backend_data).returns({})
    end
  end

  class DebTest < DebTestBase
    def test_repositories
      assert_includes @deb_one.repository_ids, @repo.id
    end

    def test_create
      pulp_id = 'dummy-uuid-999'
      assert Deb.create!(pulp_id: pulp_id, name: 'dummy')
      assert Deb.find_by_pulp_id(pulp_id)
    end

    def test_with_identifiers
      set = Deb.with_identifiers([@deb_one.id, @deb_two.pulp_id])
      assert_equal 2, set.size
      assert_includes set, @deb_one
      assert_includes set, @deb_two
    end
  end

  class DebVersionSearchTest < DebTestBase
    def create_deb(name:, version:, arch: 'amd64')
      Deb.create!(
        name: name,
        version: version,
        architecture: arch,
        pulp_id: SecureRandom.uuid,
        filename: "#{name}_#{version}_#{arch}.deb",
        repository_ids: [@repo.id]
      )
    end

    def test_search_version_greater_or_equal
      result = Deb.in_repositories(@repo).search_for('version >= 1.1')
      assert_includes result, @deb_one_v2
      refute_includes result, @deb_one
    end

    def test_search_version_less_than
      result = Deb.in_repositories(@repo).search_for('version < 1.1')
      assert_includes result, @deb_one
      refute_includes result, @deb_one_v2
    end

    def test_search_version_equal
      result = Deb.in_repositories(@repo).search_for('version = 1.0')
      assert_includes result, @deb_one
      refute_includes result, @deb_one_v2
    end

    def test_search_with_epoch_handling
      deb_epoch_2 = create_deb(name: "epochpkg", version: "2:1.0")
      deb_epoch_1 = create_deb(name: "epochpkg", version: "1:1.0")

      greater = Deb.in_repositories(@repo).search_for('version > 1:1.0')
      assert_includes greater, deb_epoch_2
      refute_includes greater, deb_epoch_1

      equal = Deb.in_repositories(@repo).search_for('version = 1:1.0')
      assert_equal [deb_epoch_1], equal
    end

    def test_search_range
      deb_0_9 = create_deb(name: 'rangepkg', version: '0.9')
      deb_1_2 = create_deb(name: 'rangepkg', version: '1.2')

      inside = Deb.in_repositories(@repo).search_for('version >= 1.0 AND version <= 1.1')
      outside = Deb.in_repositories(@repo).search_for('version < 1.0 OR version > 1.1')

      assert_includes inside, @deb_one
      assert_includes inside, @deb_one_v2
      refute_includes inside, deb_0_9
      refute_includes inside, deb_1_2

      assert_includes outside, deb_0_9
      assert_includes outside, deb_1_2
    end
  end
end
