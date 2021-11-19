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
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)
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
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)
          index_args = {:id => @repo.id, :contents_changed => true}
          ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
          @repo.reload
          post_unit_count = Katello::Erratum.all.count
          post_unit_repository_count = Katello::RepositoryErratum.where(:repository_id => @repo.id).count

          assert_equal post_unit_count, 7
          assert_equal post_unit_repository_count, 7
        end

        def test_update_model
          Katello::Erratum.destroy_all
          sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, sync_args)
          uuid = Katello::Pulp3::Erratum.content_unit_list({}).results.find { |result| result.id == ERRATA_ID }.pulp_href.as_json
          service = Katello::Pulp3::Erratum.new(uuid)
          erratum = Katello::Erratum.create!(:pulp_id => uuid)

          service.update_model(erratum)
          assert_includes Katello::Erratum::SECURITY, erratum.errata_type

          erratum.reload
          refute_empty erratum.packages
          refute erratum.packages.first.filename.blank?
          refute erratum.packages.first.nvrea.blank?
          refute erratum.packages.first.name.blank?

          refute_empty erratum.bugzillas
          refute_empty erratum.bugzillas.first.bug_id
          refute_empty erratum.bugzillas.first.href

          refute_empty erratum.cves
          refute_empty erratum.cves.first.cve_id
          refute_empty erratum.cves.first.href

          assert_equal '2010-11-10', erratum.issued.to_s
          assert_equal '2010-11-10', erratum.updated.to_s
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
