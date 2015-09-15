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
      set_user
      ::Katello::RepositorySupport.create_repo(repo.id)
    end

    def teardown
      set_user
      ::Katello::RepositorySupport.destroy_repo(repo.pulp_id)
    end
  end
end
