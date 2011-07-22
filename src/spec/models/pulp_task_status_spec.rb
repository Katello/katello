#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'spec_helper'
include OrchestrationHelper

describe PulpTaskStatus do

  context "proxy TaskStatus for pulp task" do
    let(:pulp_task_without_error) do
      {
          :id => '123',
          :state => 'waiting',
          :start_time => Time.now,
          :finish_time => Time.now,
          :result => "hurray"
      }
    end

    let(:updated_pulp_task) do
      {
          :id => '123',
          :state => 'finished',
          :start_time => Time.now,
          :finish_time => Time.now + 60,
          :result => "yippie"
      }
    end

    let(:pulp_task_with_error) do
      {
          :id => '123',
          :state => 'waiting',
          :start_time => Time.now,
          :finish_time => Time.now,
          :exception => "exception",
          :traceback => "traceback"
      }
    end

    context "TaskStatus should have correct attributes for a completed task" do
      before { @t = PulpTaskStatus.using_pulp_task(pulp_task_without_error) }

      specify { @t.uuid.should == pulp_task_without_error[:id] }
      specify { @t.state.should == pulp_task_without_error[:state] }
      specify { @t.start_time.should == pulp_task_without_error[:start_time] }
      specify { @t.finish_time.should == pulp_task_without_error[:finish_time] }
      specify { @t.result.should == pulp_task_without_error[:result] }
    end

    context "TaskStatus should have correct attributes for a failed task" do
      before { @t = PulpTaskStatus.using_pulp_task(pulp_task_with_error) }
      specify { @t.result.should == {:errors => [pulp_task_with_error[:exception], pulp_task_with_error[:traceback]]}.to_json }
    end

    context "refreshing TaskStatus with latest from pulp" do
      before(:each) do
        disable_org_orchestration

        @organization = Organization.create!(:name => 'test_org', :cp_key => 'test_org')
        @t = PulpTaskStatus.using_pulp_task(pulp_task_without_error) {|t| t.organization = @organization }
        @t.save!

        Pulp::Task.stub(:find).and_return(updated_pulp_task)
      end

      it "should fetch data from pulp" do
        Pulp::Task.should_receive(:find).once.with(@t.uuid).and_return(updated_pulp_task)
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