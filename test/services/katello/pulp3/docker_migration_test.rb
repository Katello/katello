require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class DockerMigrationTest < ActiveSupport::TestCase
        include Pulp3Support
        include VCR::TestCase

        def setup
          SETTINGS[:katello][:use_pulp_2_for_content_type] = {}
          SETTINGS[:katello][:use_pulp_2_for_content_type][:docker] = true

          @primary = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
          @repo = katello_repositories(:busybox)
          @repo.root.docker_tags_whitelist = ["latest"]
          @repo.root.url = 'https://quay.io/'
          @repo.root.docker_upstream_name = 'quay/busybox'
          @repo.root.save!

          Katello::RootRepository.docker_type.where.not(:id => @repo.root_id).destroy_all
          Katello::Repository.docker_type.where.not(:id => [@repo.id]).destroy_all

          RepositorySupport.destroy_repo(@repo)
          RepositorySupport.create_and_sync_repo(@repo)
          @repo.index_content
        end

        def teardown
          RepositorySupport.destroy_repo(@repo)
        ensure
          SETTINGS[:katello][:use_pulp_2_for_content_type][:docker] = nil
        end

        def test_docker_migration
          migration_service = Katello::Pulp3::Migration.new(SmartProxy.pulp_primary, repository_types: ['docker'])

          task = migration_service.create_and_run_migrations
          wait_on_task(@primary, task)

          migration_service.import_pulp3_content
          [@repo].each { |repo| repo.reload }

          refute_nil @repo.version_href
          assert_nil @repo.publication_href
          refute_nil @repo.remote_href
          refute_nil repository_reference(@repo)
          refute_nil distribution_reference(@repo)
        end

        def test_docker_migration_reset
          migration_service = Katello::Pulp3::Migration.new(SmartProxy.pulp_primary, repository_types: ['docker'])

          task = migration_service.create_and_run_migrations
          wait_on_task(@primary, task)

          migration_service.import_pulp3_content

          task = migration_service.reset
          wait_on_task(@primary, task)

          [@repo].each { |repo| repo.reload }

          assert_nil @repo.version_href
          assert_nil @repo.publication_href
          assert_nil @repo.remote_href
          assert_nil repository_reference(@repo)
          assert_nil distribution_reference(@repo)
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
