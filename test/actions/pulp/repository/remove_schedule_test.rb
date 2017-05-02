require 'katello_test_helper'
require_relative 'test_base.rb'

module ::Actions::Pulp::Repository
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
