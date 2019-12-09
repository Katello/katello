require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class FileUnitTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        def setup
          @master = FactoryBot.create(:smart_proxy, :default_smart_proxy, :with_pulp3)
          @repo = katello_repositories(:generic_file)
          @repo.root.update_attributes(:url => 'https://repos.fedorapeople.org/repos/pulp/pulp/fixtures/file2/')
          ensure_creatable(@repo, @master)
          create_repo(@repo, @master)
          @repo.reload
        end

        def test_index_model
          Katello::FileUnit.destroy_all
          sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)
          @repo.reload
          @repo.index_content
          post_unit_count = Katello::FileUnit.all.count
          post_unit_repository_count = Katello::RepositoryFileUnit.where(:repository_id => @repo.id).count

          assert_equal post_unit_count, 3
          assert_equal post_unit_repository_count, 3
        end

        def test_index_on_sync
          Katello::FileUnit.destroy_all
          sync_args = {:smart_proxy_id => @master.id, :repo_id => @repo.id}
          ForemanTasks.sync_task(::Actions::Pulp3::Orchestration::Repository::Sync, @repo, @master, sync_args)
          index_args = {:id => @repo.id, :contents_changed => true}
          ForemanTasks.sync_task(::Actions::Katello::Repository::IndexContent, index_args)
          @repo.reload
          post_unit_count = Katello::FileUnit.all.count
          post_unit_repository_count = Katello::RepositoryFileUnit.where(:repository_id => @repo.id).count

          assert_equal post_unit_count, 3
          assert_equal post_unit_repository_count, 3
        end
      end
    end
  end
end
