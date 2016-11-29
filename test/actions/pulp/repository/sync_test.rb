require 'katello_test_helper'

module ::Actions::Pulp::Repository
  class TestBase < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::PulpTask
    include Support::Actions::RemoteAction
  end

  class VCRTestBase < TestBase
    include VCR::TestCase
    let(:repo) { katello_repositories(:fedora_17_x86_64) }

    def setup
      set_user
      ::Katello::RepositorySupport.create_repo(repo.id)
    end

    def teardown
      ::Katello::RepositorySupport.destroy_repo
    end
  end

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
