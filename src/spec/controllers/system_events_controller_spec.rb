#
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

describe SystemEventsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include SystemHelperMethods
  include AuthorizationHelperMethods
  include UserHelperMethods
  describe "main" do
    let(:uuid) { '1234' }
    before (:each) do
      login_user(:mock => false)
      set_default_locale
      @organization = setup_system_creation
      @environment = KTEnvironment.create!(:name=>'test', :label=> 'test', :prior => @organization.library.id, :organization => @organization)

      Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Resources::Candlepin::Consumer.stub!(:update).and_return(true)
      Resources::Candlepin::Consumer.stub!(:events).and_return([])

      Runcible::Extensions::Consumer.stub!(:create).and_return({:id => uuid})
      Runcible::Extensions::Consumer.stub!(:update).and_return(true)
    end

    describe "system tasks", :katello => true do
      before do
        @system = System.create!(:name=>"bar", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})
      end
      context "shows the Tasks list" do
        before do
          User.current = @user
          stub_consumer_packages_install(pulp_task_without_error)
          @task = @system.install_packages(["foo", "bar", "bazz", "geez"])

        end
        specify "index call does the right thing" do
          get :index, :system_id => @system.id
          response.should be_success
        end

        specify "status call does the right thing" do
          get :status, :system_id => @system.id, :task_id => @task.id
          response.should be_success
          JSON.parse(response.body)["tasks"].first["id"].should == @task.id
        end

        specify "status call does the right thing for multi tasks" do
          task1 = @system.install_packages(["baz"])
          get :status, :system_id => @system.id, :task_id => [@task.id, task1.id]
          response.should be_success
          JSON.parse(response.body)["tasks"].collect{|item| item['id']}.sort.should == [@task.id, task1.id].sort
        end

      end

    end


  end
end
