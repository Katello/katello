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

          @cv_archive_repo = katello_repositories(:generic_file_archive)
          @cv_env_repo = katello_repositories(:generic_file_dev)

          Katello::RootRepository.file_type.where.not(:id => @repo.root_id).destroy_all
          Katello::Repository.file_type.where.not(:id => [@repo.id, @cv_archive_repo.id, @cv_env_repo.id]).destroy_all

          RepositorySupport.destroy_repo(@repo)
          RepositorySupport.create_and_sync_repo(@repo)
          RepositorySupport.create_repo(@cv_env_repo)
          RepositorySupport.create_repo(@cv_archive_repo)
          @repo.index_content
        end

        def teardown
          [@repo, @cv_archive_repo, @cv_env_repo].each { |repo| RepositorySupport.destroy_repo(repo) }
          SETTINGS[:katello][:use_pulp_2_for_content_type][:file] = nil
        end

        def test_file_migration
          unit = @repo.files.first

          service = Katello::Pulp::Repository::File.new(@repo, SmartProxy.pulp_master)
          service.copy_units(@cv_archive_repo, [unit])
          service.copy_units(@cv_env_repo, [unit])
          #only published repos will have their published metadata used as publications
          ForemanTasks.sync_task(Actions::Katello::Repository::MetadataGenerate, @cv_archive_repo)
          ForemanTasks.sync_task(Actions::Katello::Repository::MetadataGenerate, @cv_env_repo)

          migration_service = Katello::Pulp3::Migration.new(SmartProxy.pulp_master, ['file'])

          task = migration_service.create_and_run_migrations
          wait_on_task(@master, task)

          migration_service.import_pulp3_content
          [@repo, @cv_env_repo, @cv_archive_repo].each { |repo| repo.reload }

          refute_nil unit.reload.migrated_pulp3_href

          refute_nil @repo.version_href
          refute_nil @repo.publication_href
          refute_nil @repo.remote_href
          refute_nil repository_reference(@repo)
          refute_nil distribution_reference(@repo)

          refute_nil @cv_env_repo.version_href
          refute_nil @cv_env_repo.publication_href
          assert_nil @cv_env_repo.remote_href
          refute_nil repository_reference(@cv_env_repo)
          refute_nil distribution_reference(@cv_env_repo)

          refute_nil @cv_archive_repo.version_href
          refute_nil @cv_archive_repo.publication_href
          assert_nil @cv_archive_repo.remote_href
          refute_nil repository_reference(@cv_archive_repo)
          assert_nil distribution_reference(@cv_archive_repo)

          assert_equal repository_reference(@cv_archive_repo), repository_reference(@cv_env_repo)
          assert_equal @cv_archive_repo.version_href, @cv_env_repo.version_href
          assert_equal @cv_archive_repo.publication_href, @cv_env_repo.publication_href
        end

        def repository_reference(repo)
          Katello::Pulp3::RepositoryReference.find_by(:content_view => repo.content_view, :root_repository_id => repo.root_id)
        end

        def distribution_reference(repo)
          Katello::Pulp3::DistributionReference.find_by(:repository_id => repo.id)
        end
      end
    end
  end
end
