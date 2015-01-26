#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module Katello
  describe PulpTaskStatus, :katello => true do
    include OrchestrationHelper

    describe "proxy TaskStatus for pulp task" do
      let(:pulp_task_without_error) do
        {
          :task_id => '123',
          :state => 'waiting',
          :start_time => Time.now,
          :finish_time => Time.now,
          :result => "hurray"
        }.with_indifferent_access
      end

      let(:updated_pulp_task) do
        {
          :task_id => '123',
          :state => 'finished',
          :start_time => Time.now,
          :finish_time => Time.now + 60,
          :result => "yippie"
        }.with_indifferent_access
      end

      let(:pulp_task_with_error) do
        {
          :task_id => '123',
          :state => 'waiting',
          :start_time => Time.now,
          :finish_time => Time.now,
          :exception => "exception",
          :traceback => "traceback"
        }.with_indifferent_access
      end

      describe "TaskStatus should have correct attributes for a completed task" do
        before do
          Katello.pulp_server.resources.task.stubs(:poll).returns(pulp_task_without_error)
          @t = PulpTaskStatus.using_pulp_task(pulp_task_with_error)
        end
        specify { @t.uuid.must_equal(pulp_task_without_error[:task_id]) }
        specify { @t.state.must_equal(pulp_task_without_error[:state]) }
        specify { @t.start_time.must_equal(pulp_task_without_error[:start_time]) }
        specify { @t.finish_time.must_equal(pulp_task_without_error[:finish_time]) }
        specify { @t.result.must_equal(pulp_task_without_error[:result]) }
      end

      describe "TaskStatus should have correct attributes for a failed task" do
        before do
          Katello.pulp_server.resources.task.stubs(:poll).returns(pulp_task_with_error)
          @t = PulpTaskStatus.using_pulp_task(pulp_task_with_error)
        end
        specify { @t.result.must_equal(:errors => [pulp_task_with_error[:exception], pulp_task_with_error[:traceback]]) }
      end

      describe "refreshing TaskStatus with latest from pulp" do
        before(:each) do
          disable_org_orchestration
          @organization = Organization.create!(:name => 'test_org', :label => 'test_org')
          Katello.pulp_server.resources.task.stubs(:poll).returns(pulp_task_without_error)
          @t = PulpTaskStatus.using_pulp_task(pulp_task_without_error) do |t|
            t.organization = @organization
            t.user = users(:one)
          end
          @t.save!

          Katello.pulp_server.resources.task.stubs(:poll).returns(updated_pulp_task)
        end

        it "should fetch data from pulp" do
          Katello.pulp_server.resources.task.expects(:poll).once.with(@t.uuid).returns(updated_pulp_task)
          @t.refresh
        end

        it "should update attributes with values from pulp" do
          @t.refresh

          @t.state = updated_pulp_task[:state]
          @t.finish_time = updated_pulp_task[:finish_time]
          @t.result = updated_pulp_task[:result]
        end
      end
    end
  end
end
