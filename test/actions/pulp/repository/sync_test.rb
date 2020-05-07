require 'katello_test_helper'
require_relative 'test_base.rb'
require 'support/pulp/repository_support'

module ::Actions::Pulp::Repository
  class SyncTest < VCRTestBase
    def setup
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
      super
    end

    def test_sync
      ForemanTasks.sync_task(::Actions::Pulp::Repository::Sync, :repo_id => repo.id).main_action
      assert_equal 18, ::Katello::Pulp::Rpm.ids_for_repository(repo.pulp_id).length
    end
  end

  class BackgroundSyncTest < VCRTestBase
    def setup
      FactoryBot.create(:smart_proxy, :default_smart_proxy)
      super
    end

    def test_sync
      repo.root.update!(download_policy: 'background', url: 'http://foo.com/') if repo.yum?
      output = ForemanTasks.sync_task(::Actions::Pulp::Repository::Sync, :repo_id => repo.id).output
      download_tasks = output["pulp_tasks"].select { |task| task["tags"].include?("pulp:action:download") }

      assert_equal "background", repo.download_policy
      assert_empty download_tasks
      assert_equal 2, output['pulp_tasks'].length
    end
  end
end
