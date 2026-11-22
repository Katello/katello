require 'katello_test_helper'
require Katello::Engine.root.join('db/migrate/20261004120000_remove_event_daemon_tables')

module Katello
  class RemoveEventDaemonTablesTest < ActiveSupport::TestCase
    def setup
      @migration = ::RemoveEventDaemonTables.new
    end

    def test_schedules_pending_hosts_in_batches
      @migration.stubs(:table_exists?).with(:katello_host_queue_elements).returns(true)
      @migration.stubs(:select_values).returns(%w[1 2 3])
      Setting.stubs(:[]).with("applicability_batch_size").returns(2)
      User.stubs(:as_anonymous_admin).yields
      ForemanTasks.expects(:async_task)
        .with(::Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: [1, 2])
      ForemanTasks.expects(:async_task)
        .with(::Actions::Katello::Applicability::Hosts::BulkGenerate, host_ids: [3])

      @migration.send(:schedule_pending_applicability)
    end

    def test_does_not_schedule_without_pending_hosts
      @migration.stubs(:table_exists?).with(:katello_host_queue_elements).returns(true)
      @migration.stubs(:select_values).returns([])
      ForemanTasks.expects(:async_task).never

      @migration.send(:schedule_pending_applicability)
    end
  end
end
