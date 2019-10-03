require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class MigrationTest < ActiveSupport::TestCase
        include Pulp3Support
        include VCR::TestCase

        def setup
          SETTINGS[:katello][:use_pulp_2_for_content_type] = {}
          SETTINGS[:katello][:use_pulp_2_for_content_type][:file] = true

          @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
          @repo = katello_repositories(:generic_file)
          @repo.root.url = 'file:///var/www/test_repos/file_migration/'
          @repo.root.save!

          RepositorySupport.destroy_repo(@repo)
          RepositorySupport.create_and_sync_repo(@repo)
          @repo.index_content
        end

        def teardown
          SETTINGS[:katello][:use_pulp_2_for_content_type][:file] = nil
          RepositorySupport.destroy_repo(@repo)
        end

        def test_file_migration
          unit = @repo.files.first

          migration_service = Katello::Pulp3::Migration.new(SmartProxy.pulp_master, ['file'])

          task = migration_service.create_and_run_migration
          wait_on_task(@master, task)

          migration_service.import_pulp3_content

          refute_nil unit.reload.migrated_pulp3_href
        end
      end
    end
  end
end
