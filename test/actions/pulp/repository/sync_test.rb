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

    def run_action(action_class, *args)
      ForemanTasks.sync_task(action_class, *args).main_action
    end

    def setup
      ::Katello::RepositorySupport.create_repo(repo.id)
    end

    def teardown
      ::Katello::RepositorySupport.destroy_repo
    end
  end

  class SyncTest < VCRTestBase
    let(:action_class) { ::Actions::Pulp::Repository::Sync }
    def test_sync
      run_action(action_class, pulp_id: repo.pulp_id)
      assert_equal 8, repo.rpm_ids.length
    end
  end
end
