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

require 'katello_test_helper'

module Katello
describe SyncPlansController do

  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  describe "(katello)" do

  describe "rules" do
    before (:each) do
      new_test_org
      setup_controller_defaults
      @controller.stubs(:search_validate).returns(true)
    end
    describe "GET index" do
      before do
        @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@organization)
      end
      let(:action) {:items}
      let(:req) { get :items}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :providers, @provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "Manage test" do
      let(:action) {:new}
      let(:req) { get :new}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:sync, :organizations, nil, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
  end

  describe "other-tests" do
    before (:each) do
      setup_controller_defaults
      @controller.stubs(:search_validate).returns(true)
      @org = new_test_org
      @controller.stubs(:current_organization).returns(@org)
    end
      let(:plan_create) do
        {
          :sync_plan => {
                         :name => 'myplan',
                         :interval => 'weekly',
                         :plan_date =>'01/01/2011',
                         :plan_time => '07:00 am',
                         :description => 'RSPEC me'
                        }
        }
      end

    describe "GET 'index'" do
      it "should be successful" do
        get :index
        must_respond_with(:success)
        must_render_template("index")
      end
    end

    describe "Create a SyncPlan" do

      it "should create a plan successfully" do
        must_notify_with(:success)
        post :create, plan_create
        SyncPlan.first.wont_be_nil
        must_respond_with(:success)
      end

      it "should have a valid date" do
        must_notify_with(:error)
        plan_create[:sync_plan].wont_be_nil
        data = plan_create
        data[:sync_plan][:plan_date] = '01/101/11'
        post :create, data
        response.must_respond_with(400)
      end

      it "should have a unique name" do
        must_notify_with(:exception)
        SyncPlan.create!  :name => 'myplan', :interval => 'weekly', :sync_date => DateTime.now, :organization => @controller.current_organization
        post :create, plan_create
        response.must_respond_with(422)
      end

      it "should not have a nil name" do
        must_notify_with(:exception)
        data = plan_create
        data[:sync_plan][:name] = ''
        post :create, data
        response.must_respond_with(422)
      end

      let(:req) do
        bad_params = plan_create
        bad_params[:sync_plan][:bad_foo] = "gah"
        post :create, bad_params
      end

      it_should_behave_like "bad request"
    end

    describe "Delete a SyncPlan" do
      it "should delete a sync plan successfully" do
        plan = SyncPlan.create!  :name => 'myplan', :interval => 'weekly', :sync_date => DateTime.now, :organization => @controller.current_organization
        @controller.stubs(:render).returns("") #ignore missing js partial
        SyncPlan.first.wont_be_nil
        must_notify_with(:success)
        delete :destroy, :id => plan.id
      end
    end

    describe "Update a SyncPlan" do
      before (:each) do
        @plan = SyncPlan.create! :name => 'myplan', :interval => 'weekly', :sync_date => DateTime.now, :organization => @controller.current_organization
      end

      it "should update a sync plan name successfully" do
        SyncPlan.first.wont_be_nil
        must_notify_with(:success)
        put :update, :id => @plan.id, :sync_plan => {:name => 'yourplan'}
        must_respond_with(:success)
      end

      it "should update a sync plan interval successfully" do
        SyncPlan.first.wont_be_nil
        must_notify_with(:success)
        put :update, :id => @plan.id, :sync_plan => {:interval => 'daily'}
        must_respond_with(:success)
      end

      it "should update interval to none successfully" do
        SyncPlan.first.wont_be_nil
        must_notify_with(:success)
        put :update, :id => @plan.id, :sync_plan => {:interval => 'none'}
        must_respond_with(:success)
      end

      it "should update a sync plan description successfully" do
        SyncPlan.first.wont_be_nil
        must_notify_with(:success)
        put :update, :id => @plan.id, :sync_plan => {:description => 'Would rather be fishing then writing tests'}
        must_respond_with(:success)
      end

      it "should update a sync time description successfully" do
        SyncPlan.first.wont_be_nil
        must_notify_with(:success)
        put :update, :id => @plan.id, :sync_plan => {:time => '12:00 pm'}
        must_respond_with(:success)
      end

      it "should update a sync date description successfully" do
        SyncPlan.first.wont_be_nil
        must_notify_with(:success)
        put :update, :id => @plan.id, :sync_plan => {:date => '11/11/11'}
        must_respond_with(:success)
      end

      it "should not update bad sync dates" do
        SyncPlan.first.wont_be_nil
        must_notify_with(:error)
        put :update, :id => @plan.id, :sync_plan => {:date => '11/111111/11'}
        response.must_respond_with(400)
      end

      it "should not update bad sync time" do
        SyncPlan.first.wont_be_nil
        must_notify_with(:error)
        put :update, :id => @plan.id, :sync_plan => {:time => '30:00 pmm'}
        response.must_respond_with(400)
      end

      it "should not update a blank name" do
        SyncPlan.first.wont_be_nil
        must_notify_with(:exception)
        put :update, :id => @plan.id, :sync_plan => {:name => ''}
        response.must_respond_with(422)
      end

      let(:req) do
        bad_params =  {:id => @plan.id, :sync_plan => {:name => '122'}}
        bad_params[:sync_plan][:bad_foo] = "gah"
        post :create, bad_params
      end

      it_should_behave_like "bad request"
    end
  end
  end
end
end
