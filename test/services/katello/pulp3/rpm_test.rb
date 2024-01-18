require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class RpmTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        def setup
          @primary = SmartProxy.pulp_primary
          @repo = katello_repositories(:fedora_17_x86_64_duplicate)
          @repo.root.update(:url => 'https://jlsherrill.fedorapeople.org/fake-repos/needed-errata/')
          ensure_creatable(@repo, @primary)
          create_repo(@repo, @primary)

          @repo.reload
        end

        def test_index_model
          Katello::Rpm.destroy_all
          sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
          @repo.reload
          @repo.index_content
          post_unit_count = Katello::Rpm.all.count
          post_unit_repository_count = Katello::RepositoryRpm.where(:repository_id => @repo.id).count

          assert_equal post_unit_count, 32
          assert_equal post_unit_repository_count, 32

          assert_equal 'bear-4.1-1.noarch', @repo.rpms.where(:name => 'bear').first.nvra
        end

        def test_index_on_sync
          Katello::Rpm.destroy_all
          sync_args = {:smart_proxy_id => @primary.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @primary, **sync_args)
          index_args = {:id => @repo.id, :contents_changed => true}
          ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
          @repo.reload
          post_unit_count = Katello::Rpm.all.count
          post_unit_repository_count = Katello::RepositoryRpm.where(:repository_id => @repo.id).count

          assert_equal post_unit_count, 32
          assert_equal post_unit_repository_count, 32
        end
      end
    end
  end
end
