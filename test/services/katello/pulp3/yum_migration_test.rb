require 'katello_test_helper'
require 'support/pulp3_support'

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
module Katello
  module Service
    module Pulp3
      class YumMigrationTestBase < ActiveSupport::TestCase
        include Pulp3Support
        include VCR::TestCase

        def setup
          SETTINGS[:katello][:use_pulp_2_for_content_type] = {}
          SETTINGS[:katello][:use_pulp_2_for_content_type][:yum] = true

          @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)

          @library_repo = katello_repositories(:rhel_6_x86_64)

          @component_archive_repo = katello_repositories(:rhel_6_x86_64_library_view_1_archive)
          @component_env_repo = katello_repositories(:rhel_6_x86_64_library_view_1)

          @composite_env = katello_repositories(:rhel_6_x86_64_composite_view_version_1)
          @composite_archive = katello_repositories(:rhel_6_x86_64_composite_view_version_1_archive)

          @repos = [@library_repo, @component_archive_repo, @component_env_repo, @composite_archive, @composite_env]
          @repos.each { |repo| repo.repository_errata.delete_all }

          Katello::Repository.yum_type.where.not(:environment_id => Katello::KTEnvironment.library).where.not(:id => [@repos]).destroy_all
          Katello::Repository.yum_type.where.not(:id => [@repos]).destroy_all
          Katello::RootRepository.yum_type.where.not(:id => @library_repo.root_id).destroy_all

          RepositorySupport.destroy_repo(@library_repo)
          RepositorySupport.create_repo(@library_repo, false)
          RepositorySupport.sync_repo(@library_repo)

          (@repos - [@library_repo]).each { |repo| RepositorySupport.create_repo(repo, false) }

          @library_repo.backend_service(@master).copy_contents(@component_archive_repo)
          @repos.each { |repo| ForemanTasks.sync_task(Actions::Katello::Repository::MetadataGenerate, repo) }

          @library_repo.index_content
        end

        def teardown
          @repos.each { |repo| RepositorySupport.destroy_repo(repo) }
        ensure
          SETTINGS[:katello][:use_pulp_2_for_content_type] = {}
        end
      end

      class YumMigrationTest < YumMigrationTestBase
        def test_yum_migration
          migration_service = Katello::Pulp3::Migration.new(SmartProxy.pulp_primary, ['yum'])

          task = migration_service.create_and_run_migrations
          wait_on_task(@master, task)
          migration_service.import_pulp3_content

          @repos.each(&:reload)

          refute_nil @library_repo.version_href
          refute_nil @library_repo.publication_href
          refute_nil @library_repo.remote_href
          refute_nil repository_reference(@library_repo)
          refute_nil distribution_reference(@library_repo)

          refute_nil @component_archive_repo.version_href
          refute_nil @component_archive_repo.publication_href
          assert_nil @component_archive_repo.remote_href
          refute_nil repository_reference(@component_archive_repo)
          refute_nil distribution_reference(@component_archive_repo)

          refute_nil @component_env_repo.version_href
          refute_nil @component_env_repo.publication_href
          assert_nil @component_env_repo.remote_href

          refute_nil repository_reference(@component_env_repo)
          refute_nil distribution_reference(@component_env_repo)

          assert_equal @component_archive_repo.version_href, @component_env_repo.version_href
          assert_equal @component_archive_repo.publication_href, @component_env_repo.publication_href

          refute_nil @composite_archive.version_href
          refute_nil @composite_archive.publication_href
          assert_nil @composite_archive.remote_href
          refute_nil repository_reference(@composite_archive)
          refute_nil distribution_reference(@composite_archive)

          assert_equal @composite_archive.version_href, @component_archive_repo.version_href
          assert_equal @composite_archive.publication_href, @component_archive_repo.publication_href

          refute_nil @composite_env.version_href
          refute_nil @composite_env.publication_href
          assert_nil @composite_env.remote_href
          refute_nil repository_reference(@composite_env)
          refute_nil distribution_reference(@composite_env)

          assert_equal @composite_archive.version_href, @composite_env.version_href
          assert_equal @composite_archive.publication_href, @composite_env.publication_href

          refute_empty @library_repo.repository_errata
          assert_empty @library_repo.repository_errata.where(:erratum_pulp3_href => nil)

          refute_empty @component_archive_repo.repository_errata
          assert_empty @component_archive_repo.repository_errata.where(:erratum_pulp3_href => nil)

          refute_empty @component_env_repo.repository_errata
          assert_empty @component_env_repo.repository_errata.where(:erratum_pulp3_href => nil)

          refute_empty @composite_env.repository_errata
          assert_empty @composite_env.repository_errata.where(:erratum_pulp3_href => nil)

          refute_empty @composite_archive.repository_errata
          assert_empty @composite_archive.repository_errata.where(:erratum_pulp3_href => nil)
        end

        def repository_reference(repo)
          Katello::Pulp3::RepositoryReference.find_by(:content_view => repo.content_view, :root_repository_id => repo.root_id)
        end

        def distribution_reference(repo)
          Katello::Pulp3::DistributionReference.find_by(:repository_id => repo.id)
        end
      end

      class YumMasterCompositeMigrationTest < YumMigrationTestBase
        def setup
          super
          #same as the other test, but make the composite have multiple components
          @other_component_view = Katello::ContentView.create!(:name => 'OtherComponent', :organization => @library_repo.organization)
          @other_component_version = Katello::ContentViewVersion.create!(:major => 1, :minor => 0, :content_view => @other_component_view)
          @other_component_repo = Katello::Repository.create!(:pulp_id => "other_component_repo", :relative_path => 'other_component/1.0/repo',
                                                              :root_id => @library_repo.root_id, :content_view_version => @other_component_version,
                                                              :library_instance => @library_repo)

          @other_component_version.composites << @composite_archive.content_view_version
          RepositorySupport.create_repo(@other_component_repo, false)
        end

        def teardown
          RepositorySupport.destroy_repo(@other_component_repo)
          super
        end

        def test_yum_migration_master_composite
          migration_service = Katello::Pulp3::Migration.new(SmartProxy.pulp_primary, ['yum'])

          task = migration_service.create_and_run_migrations
          wait_on_task(@master, task)
          migration_service.import_pulp3_content

          @repos.each(&:reload)
          @other_component_repo.reload

          refute_nil @other_component_repo.publication_href
          refute_nil @other_component_repo.version_href

          refute_nil @composite_archive.publication_href
          refute_nil @composite_archive.version_href

          refute_equal @other_component_repo.version_href, @composite_archive.version_href
          refute_equal @other_component_repo.publication_href, @composite_archive.publication_href

          refute_equal @component_archive_repo.version_href, @composite_archive.version_href
          refute_equal @component_archive_repo.publication_href, @composite_archive.publication_href
        end
      end
    end
  end
end
