
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

require 'katello_test_helper'

module Katello
describe SystemGroupEventsController do

  include LocaleHelperMethods
  include SystemHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper
  include OrganizationHelperMethods

  describe "main" do
    let(:uuid) { '1234' }
    before (:each) do
      setup_controller_defaults
      disable_org_orchestration
      disable_consumer_group_orchestration

      @org = Organization.create!(:name=>'test_org', :label=> 'test_org')
      @environment = create_environment(:name=>"DEV", :label=> "DEV", :prior=>@org.library, :organization=>@org)

      Resources::Candlepin::Consumer.stubs(:create).returns({:uuid => uuid, :owner => {:key => uuid}})
      Resources::Candlepin::Consumer.stubs(:update).returns(true)

      Katello.pulp_server.extensions.consumer.stubs(:create).returns({:id => uuid})
      Katello.pulp_server.extensions.consumer.stubs(:update).returns(true)

      @group = SystemGroup.new(:name=>"test_group", :organization=>@org)
      @system = create_system(:name=>"verbose", :environment => @environment, :cp_type=>"system", :facts=>{"Test1"=>1, "verbose_facts" => "Test facts"})
      @group.save!
      @group.systems << @system

      SystemGroup.stubs(:find).returns(@group)
      @job = OpenStruct.new(:pulp_id => "job_pulp_id_123", :id => 1)
    end

    describe "system group jobs (katello)" do

      describe 'index' do
        before (:each) do
          @controller.stubs(:jobs).returns([@job])
        end

        it "should be successful" do
          get :index, :system_group_id => @group.id
          must_respond_with(:success)
        end
      end

      describe 'show' do
        before (:each) do
          where = stub
          where.stubs(:where).returns([@job])
          @group.stubs(:jobs).returns(where)
        end

        it "should be successful" do
          @controller.expects(:render).twice
          get :show, :system_group_id => @group.id, :id => @job.id
          must_respond_with(:success)
        end
      end

      describe 'event_status' do
        before (:each) do
          @controller.stubs(:render_to_string).returns("")
          @job.stubs(:pending?).returns(true)
        end

        it "should return a job" do
          where = stub
          where.stubs(:where).returns([@job])
          @group.stubs(:refreshed_jobs).returns(where)

          get :event_status, :system_group_id => @group.id, :job_id => @job.id
          must_respond_with(:success)
          JSON.parse(response.body)["jobs"].first["id"].must_equal @job.id
        end

        it "should return multiple jobs" do
          job1 = OpenStruct.new(:pulp_id => "job_pulp_id_456", :id => 2)
          job1.stubs(:pending?).returns(true)
          where = stub
          where.stubs(:where).returns([@job, job1])
          @group.stubs(:refreshed_jobs).returns(where)

          get :event_status, :system_group_id => @group.id, :job_id => [@job.id, job1.id]
          must_respond_with(:success)
          JSON.parse(response.body)["jobs"].collect{|item| item['id']}.sort.must_equal [@job.id, job1.id].sort
        end

        it "should be successful" do
          @job.stubs(:pending?).returns(true)
          where = stub
          where.stubs(:where).returns([@job])
          @group.stubs(:refreshed_jobs).returns(where)

          get :event_status, :system_group_id => @group.id, :job_id => [@job.id]
          must_respond_with(:success)
        end

      end
    end
  end
end
end
