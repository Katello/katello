require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Service
    class PackageGroupTestBase < ActiveSupport::TestCase
      include RepositorySupport

      @@package_group_id = nil

      def setup
        User.current = User.find(FIXTURES['users']['admin']['id'])

        VCR.insert_cassette('services/pulp/package_group')

        repository_id = FIXTURES['katello_repositories']['fedora_17_x86_64']['id']
        RepositorySupport.create_and_sync_repo(repository_id)

        @@package_groups = RepositorySupport.repo.package_groups

        @@package_group_names = ['bird', 'mammal']
      end

      def teardown
        RepositorySupport.destroy_repo
        VCR.eject_cassette
      end
    end

    class PackageGroupTest < PackageGroupTestBase
      def test_repo_package_groups
        RepositorySupport.repo.index_db_package_groups
        assert_equal 2, @@package_groups.length
        assert_equal @@package_group_names, @@package_groups.map(&:name).sort
      end

      def test_pulp_data
        RepositorySupport.repo.index_db_package_groups
        assert_equal @@package_group_names[0], Pulp::PackageGroup.pulp_data(@@package_groups.sort_by(&:name).first.uuid)['id']
      end

      def test_update_from_json
        RepositorySupport.repo.index_db_package_groups
        uuid = @@package_groups.first.uuid
        PackageGroup.where(:uuid => uuid).first.destroy! if PackageGroup.exists?(:uuid => uuid)
        package_group = PackageGroup.create!(:uuid => uuid)
        package_group_data = Pulp::PackageGroup.pulp_data(uuid)
        package_group.update_from_json(package_group_data)
        assert_equal package_group.name, package_group_data["name"]
      end
    end
  end
end
