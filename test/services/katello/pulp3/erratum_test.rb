require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class ErratumTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        ERRATA_ID = 'KATELLO-RHSA-2010:0858'.freeze

        def setup
          @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
          @repo = katello_repositories(:fedora_17_x86_64_duplicate)
          @repo.root.update_attributes(:url => 'file:///var/www/test_repos/zoo')
          ensure_creatable(@repo, @master)
          create_repo(@repo, @master)
          @repo.reload
        end

        def teardown
          ForemanTasks.sync_task(
            ::Actions::Pulp3::Orchestration::Repository::Delete, @repo, @master)
          @repo.reload
        end

        def test_index_model
          Katello::Erratum.destroy_all
          sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)
          @repo.reload
          @repo.index_content
          post_unit_count = Katello::Erratum.all.count
          post_unit_repository_count = Katello::RepositoryErratum.where(:repository_id => @repo.id).count

          assert_equal post_unit_count, 6
          assert_equal post_unit_repository_count, 6
        end

        def test_index_on_sync
          Katello::Erratum.destroy_all
          sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)
          index_args = {:id => @repo.id, :contents_changed => true}
          ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
          @repo.reload
          post_unit_count = Katello::Erratum.all.count
          post_unit_repository_count = Katello::RepositoryErratum.where(:repository_id => @repo.id).count

          assert_equal post_unit_count, 6
          assert_equal post_unit_repository_count, 6
        end

        def test_update_model
          Katello::Erratum.destroy_all
          sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)
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
        end
      end
    end
  end
end
