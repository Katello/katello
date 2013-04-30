
# Copyright 2013 Red Hat, Inc.
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

describe SystemGroupEventsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include SystemHelperMethods
  include AuthorizationHelperMethods
  include UserHelperMethods

  describe "main" do
    let(:uuid) { '1234' }
    before (:each) do
      login_user
      set_default_locale
      disable_org_orchestration
      disable_consumer_group_orchestration

      @org = Organization.create!(:name=>'test_org', :label=> 'test_org')
      @environment = KTEnvironment.create!(:name=>"DEV", :label=> "DEV", :prior=>@org.library, :organization=>@org)

      Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Resources::Candlepin::Consumer.stub!(:update).and_return(true)

      Runcible::Extensions::Consumer.stub!(:create).and_return({:id => uuid})
      Runcible::Extensions::Consumer.stub!(:update).and_return(true)

      @group = SystemGroup.new(:name=>"test_group", :organization=>@org)
      @system = System.create!(:name=>"verbose", :environment => @environment, :cp_type=>"system", :facts=>{"Test1"=>1, "verbose_facts" => "Test facts"})
      @group.save!
      @group.systems << @system

      SystemGroup.stub!(:find).and_return(@group)
      @job = mock_model(Job, :pulp_id => "job_pulp_id_123")
    end

    describe "system group jobs", :katello => true do

      describe 'index' do
        before (:each) do
          controller.stub!(:jobs).and_return([@job])
        end

        it "should render the index partial" do
          get :index, :system_group_id => @group.id
          response.should render_template(:partial => 'system_groups/events/_index')
        end

        it "should be successful" do
          get :index, :system_group_id => @group.id
          response.should be_success
        end
      end

      describe 'show' do
        before (:each) do
          @group.stub_chain(:jobs, :where, :first).and_return(@job)
        end

        it "should render the show partial" do
          get :show, :system_group_id => @group.id, :id => @job.id
          response.should render_template(:partial => 'system_groups/events/_show')
        end

        it "should be successful" do
          get :show, :system_group_id => @group.id, :id => @job.id
          response.should be_success
        end
      end

      describe 'event_status' do
        before (:each) do
          @job.stub!(:pending?).and_return(true)
        end

        it "should return a job" do
          @group.stub_chain(:refreshed_jobs, :where).and_return([@job])

          get :event_status, :system_group_id => @group.id, :job_id => @job.id
          response.should be_success
          JSON.parse(response.body)["jobs"].first["id"].should == @job.id
        end

        it "should return multiple jobs" do
          job1 = mock_model(Job, :pulp_id => "job_pulp_id_456")
          job1.stub!(:pending?).and_return(true)
          @group.stub_chain(:refreshed_jobs, :where).and_return([@job, job1])

          get :event_status, :system_group_id => @group.id, :job_id => [@job.id, job1.id]
          response.should be_success
          JSON.parse(response.body)["jobs"].collect{|item| item['id']}.sort.should == [@job.id, job1.id].sort
        end

        it "should be successful" do
          @job.stub!(:pending?).and_return(true)
          @group.stub_chain(:refreshed_jobs, :where).and_return([@job])

          get :event_status, :system_group_id => @group.id, :job_id => [@job.id]
          response.should be_success
        end

      end
    end
  end
end
