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
      ::Katello::RepositorySupport.destroy_repo
    end
  end

  class UpdateScheduleTest < VCRTestBase
    let(:action_class) { ::Actions::Pulp::Repository::UpdateSchedule }

    def create_schedule
      format = "R1/030-01-01T05:00:00Z/P1D"
      run_action(action_class, repo_id: repo.id, schedule: format)
    end

    def setup
      super
      create_schedule
    end

    def test_update_schedule
      format = "R1/030-01-01T05:00:00Z/P1D"
      run_action(action_class, repo_id: repo.id, schedule: format)
      schedules = Katello.pulp_server.resources.repository_schedule.list(repo.pulp_id, repo.importer_type)

      assert_equal schedules.first['schedule'], format
    end

    def test_disable_schedule
      run_action(action_class, repo_id: repo.id, enabled: false)
      schedules = Katello.pulp_server.resources.repository_schedule.list(repo.pulp_id, repo.importer_type)

      refute schedules[0]['enabled']
    end
  end
end
