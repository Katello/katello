require 'katello_test_helper'
require 'support/pulp3_support'

module Katello
  module Service
    module Pulp3
      class TaskGroupTest < ActiveSupport::TestCase
        include Katello::Pulp3Support

        def setup
          @primary = SmartProxy.pulp_primary
        end

        def test_error_no_errors
          group_data = {
            "pulp_href": "/pulp/api/v3/task-groups/d9841aaa-8a47-4e31-9018-10e4430766bf/",
            "description": "Migration Sub-tasks",
            "waiting": 0,
            "skipped": 0,
            "running": 1,
            "completed": 0,
            "canceled": 0,
            "failed": 0,
          }
          group = Katello::Pulp3::TaskGroup.new(@primary, group_data)
          refute group.error
        end

        def test_error_with_errors
          group_data = {
            "pulp_href": "/pulp/api/v3/task-groups/d9841aaa-8a47-4e31-9018-10e4430766bf/",
            "description": "Migration Sub-tasks",
            "waiting": 0,
            "skipped": 0,
            "running": 0,
            "completed": 0,
            "canceled": 0,
            "failed": 1,
          }
          group = Katello::Pulp3::TaskGroup.new(@primary, group_data)
          assert group.error

          group_data['running'] = 1
          group = Katello::Pulp3::TaskGroup.new(@primary, group_data)
          refute group.error
        end

        def test_error_with_cancelled
          group_data = {
            "pulp_href": "/pulp/api/v3/task-groups/d9841aaa-8a47-4e31-9018-10e4430766bf/",
            "description": "Migration Sub-tasks",
            "waiting": 0,
            "skipped": 0,
            "running": 0,
            "completed": 0,
            "canceled": 1,
            "failed": 0,
          }
          group = Katello::Pulp3::TaskGroup.new(@primary, group_data)
          assert group.error

          group_data['completed'] = 1
          group = Katello::Pulp3::TaskGroup.new(@primary, group_data)
          assert group.error

          group_data['running'] = 1
          group = Katello::Pulp3::TaskGroup.new(@primary, group_data)
          refute group.error
        end
      end
    end
  end
end
