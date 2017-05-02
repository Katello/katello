require 'katello_test_helper'
require_relative 'test_base.rb'

module ::Actions::Pulp::Repository
  class SyncTest < VCRTestBase
    def test_sync
      ForemanTasks.sync_task(::Actions::Pulp::Repository::Sync, :pulp_id => repo.pulp_id).main_action
      assert_equal 8, ::Katello::Pulp::Rpm.ids_for_repository(repo.pulp_id).length
    end
  end

  class BackgroundSyncTest < VCRTestBase
    let(:repo) { katello_repositories(:rhel_7_x86_64) }

    def test_sync
      output = ForemanTasks.sync_task(::Actions::Pulp::Repository::Sync, :pulp_id => repo.pulp_id).output
      download_tasks = output["pulp_tasks"].select { |task| task["tags"].include?("pulp:action:download") }
      assert_equal "background", repo.download_policy
      assert_empty download_tasks
      assert_equal 2, output['pulp_tasks'].length
    end
  end
end
