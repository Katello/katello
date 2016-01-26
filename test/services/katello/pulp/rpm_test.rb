require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Services
    class RpmTestBase < ActiveSupport::TestCase
      include RepositorySupport

      @@package_id = nil

      def setup
        User.current = users(:admin)
        VCR.insert_cassette('services/pulp/rpm')
        repo = Repository.find(@loaded_fixtures['katello_repositories']['fedora_17_x86_64']['id'])
        RepositorySupport.create_and_sync_repo(repo.id)
        repo.index_db_rpms
        @package_id = RepositorySupport.repo.rpms.first.id
      end

      def teardown
        RepositorySupport.destroy_repo
        VCR.eject_cassette
        User.current = nil
      end
    end

    class RpmTest < RpmTestBase
      def test_find
        package = Rpm.find(@package_id)

        refute_nil package
        refute_empty Katello::Pulp::Rpm.new(package.uuid).backend_data
      end

      def test_requires
        package = Rpm.find(@package_id)
        backend_rpm = Katello::Pulp::Rpm.new(package.uuid)
        refute_empty backend_rpm .requires
        refute_empty backend_rpm .provides
      end

      def test_ignored_fields
        refute_includes Katello::Pulp::Rpm::PULP_SELECT_FIELDS, 'changelog'
        refute_includes Katello::Pulp::Rpm::PULP_SELECT_FIELDS, 'repodata'
        refute_includes Katello::Pulp::Rpm::PULP_SELECT_FIELDS, 'filelist'
      end
    end
  end
end
