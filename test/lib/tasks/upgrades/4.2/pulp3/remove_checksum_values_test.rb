require 'katello_test_helper'
require 'rake'

module Katello
  module Upgrades
    class RemoveChecksumValuesTest < ActiveSupport::TestCase
      include Katello::Pulp3Support

      REPO_NAME = 'checksum_test'.freeze

      def setup
        Rake.application.rake_require 'katello/tasks/upgrades/4.2/remove_checksum_values'
        Rake::Task['katello:upgrades:4.2:remove_checksum_values'].reenable
        Rake::Task.define_task(:environment)

        @api = Katello::Pulp3::Api::Yum.new(SmartProxy.pulp_primary)
        if (found = @api.repositories_api.list(name => REPO_NAME).results.first)
          wait_on_task(SmartProxy.pulp_primary, @api.repositories_api.delete(found.pulp_href))
        end
        @api.repositories_api.create(name: REPO_NAME,
                                     metadata_checksum_type: 'sha256',
                                     package_checksum_type: 'sha256')
      end

      def teardown
        if (found = @api.repositories_api.list(name => REPO_NAME).results.first)
          wait_on_task(SmartProxy.pulp_primary, @api.repositories_api.delete(found.pulp_href))
        end
      end

      def test_removes_checksums
        repo = @api.repositories_api.list(name => REPO_NAME).results.first
        assert repo
        assert_equal 'sha256', repo.metadata_checksum_type
        assert_equal 'sha256', repo.package_checksum_type

        Rake.application.invoke_task('katello:upgrades:4.2:remove_checksum_values')

        until @api.tasks_api.list(state__in: ['running', 'waiting']).results.empty?
          sleep 1
        end

        repo = @api.repositories_api.list(name => REPO_NAME).results.first
        refute repo.metadata_checksum_type
        refute repo.package_checksum_type
      end
    end
  end
end
