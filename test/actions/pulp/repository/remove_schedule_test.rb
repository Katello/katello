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

  class RemoveScheduleTest < VCRTestBase
    let(:action_class) { ::Actions::Pulp::Repository::RemoveSchedule }

    def create_schedule
      format = "R1/" << Time.now.iso8601 << "/P1D"
      run_action(action_class, repo_id: repo.id, schedule: format)
    end

    def setup
      super
      create_schedule
    end

    def test_remove_schedule
      run_action(action_class, repo_id: repo.id)
      schedules = Katello.pulp_server.resources.repository_schedule.list(repo.pulp_id, repo.importer_type)

      assert_empty schedules
    end
  end
end
