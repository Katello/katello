require 'katello_test_helper'
require_relative 'test_base.rb'

module ::Actions::Pulp::Repository
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
