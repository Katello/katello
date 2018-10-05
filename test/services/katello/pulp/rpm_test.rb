require 'katello_test_helper'
require 'support/pulp/repository_support'

module Katello
  module Services
    class RpmTestBase < ActiveSupport::TestCase
      include RepositorySupport

      def setup
        User.current = users(:admin)

        @repo = katello_repositories(:fedora_17_x86_64)

        RepositorySupport.create_and_sync_repo(@repo)
        Katello::Rpm.import_for_repository(@repo, true)
        @package_id = @repo.rpms.first.id
      end

      def teardown
        RepositorySupport.destroy_repo(@repo)
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
