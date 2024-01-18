require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class ErratumTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        ERRATA_ID = 'KATELLO-RHSA-2010:0858'.freeze

        def setup
          @primary = SmartProxy.pulp_primary
          @repo = katello_repositories(:fedora_17_x86_64_duplicate)
          @repo.root.update(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo')
          ensure_creatable(@repo, @primary)
          create_repo(@repo, @primary)
          @repo.reload
        end

        def teardown
          ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @primary)
          @repo.reload
        end

        def test_index_model
          Katello::Erratum.destroy_all
          sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
          @repo.reload
          @repo.index_content
          post_unit_count = Katello::Erratum.all.count
          post_unit_repository_count = Katello::RepositoryErratum.where(:repository_id => @repo.id).count

          assert_equal post_unit_count, 7
          assert_equal post_unit_repository_count, 7
        end

        def test_index_on_sync
          Katello::Erratum.destroy_all
          sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
          index_args = {:id => @repo.id, :contents_changed => true}
          ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
          @repo.reload
          post_unit_count = Katello::Erratum.all.count
          post_unit_repository_count = Katello::RepositoryErratum.where(:repository_id => @repo.id).count

          assert_equal post_unit_count, 7
          assert_equal post_unit_repository_count, 7
        end

        def test_updates_href
          Katello::Erratum.destroy_all
          ::Katello::Pulp3::Repository.any_instance.stubs(:ssl_remote_options).returns({})

          repo_1 = katello_repositories(:rhel_7_x86_64)
          repo_1.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo2', :download_policy => 'immediate')
          ensure_creatable(repo_1, @primary)
          create_repo(repo_1, @primary)
          repo_1.reload
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, repo_1, @primary, :smart_proxy_id => @primary.id, :repo_id => repo_1.id)
          ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, :id => repo_1.id, :contents_changed => true)
          repo_1.reload
          post_unit_count, post_unit_repository_count = Katello::Erratum.all.count, Katello::RepositoryErratum.where(:repository_id => repo_1.id).count
          assert_equal post_unit_count, 3
          assert_equal post_unit_repository_count, 3

          errata_id_list = repo_1.errata.pluck(:errata_id).sort
          errata = Katello::Erratum.find_by(:errata_id => 'RHEA-2012:0059')
          old_href = repo_1.repository_errata.find_by(erratum_id: errata.id).erratum_pulp3_href

          repo_1.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo2_dup')
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, repo_1, @primary, :smart_proxy_id => @primary.id, :repo_id => repo_1.id)
          ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, :id => repo_1.id, :contents_changed => true)
          repo_1.reload
          errata = Katello::Erratum.find_by(:errata_id => 'RHEA-2012:0059')
          new_href = repo_1.repository_errata.find_by(erratum_id: errata.id).erratum_pulp3_href

          refute_equal old_href, new_href
          assert_equal errata_id_list, repo_1.errata.pluck(:errata_id).sort
        end

        def test_dup_errata
          Katello::Erratum.destroy_all
          ::Katello::Pulp3::Repository.any_instance.stubs(:ssl_remote_options).returns({})

          repo_1 = katello_repositories(:rhel_7_x86_64)
          repo_1.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo2', :download_policy => 'immediate')
          ensure_creatable(repo_1, @primary)
          create_repo(repo_1, @primary)
          repo_1.reload
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, repo_1, @primary, :smart_proxy_id => @primary.id, :repo_id => repo_1.id)
          ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, :id => repo_1.id, :contents_changed => true)
          repo_1.reload
          post_unit_count, post_unit_repository_count = Katello::Erratum.all.count, Katello::RepositoryErratum.where(:repository_id => repo_1.id).count
          assert_equal post_unit_count, 3
          assert_equal post_unit_repository_count, 3

          repo_2 = katello_repositories(:rhel_6_x86_64)
          repo_2.root.update!(:url => 'file:///var/lib/pulp/sync_imports/test_repos/zoo2_dup', :download_policy => 'immediate')
          ensure_creatable(repo_2, @primary)
          create_repo(repo_2, @primary)
          repo_2.reload
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, repo_2, @primary, :smart_proxy_id => @primary.id, :repo_id => repo_2.id)
          ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, :id => repo_2.id, :contents_changed => true)

          repo_2.reload
          post_unit_count = Katello::Erratum.all.count
          post_unit_repository_count = Katello::RepositoryErratum.where(:repository_id => repo_2.id).count

          assert_equal post_unit_count, 3
          assert_equal post_unit_repository_count, 3
        ensure
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Delete, repo_1, @primary)
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Delete, repo_2, @primary)
        end
      end
    end
  end
end
