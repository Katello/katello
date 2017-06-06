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


describe SyncPlansController, :katello => true do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  describe "rules" do
    before (:each) do
      new_test_org
      controller.stub(:search_validate).and_return(true)
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
      login_user
      set_default_locale
      controller.stub(:search_validate).and_return(true)
      @org = new_test_org
      controller.stub!(:current_organization).and_return(@org)
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
        response.should be_success
        response.should render_template("index")
      end
    end

    describe "Create a SyncPlan" do

      it "should create a plan successfully" do
        controller.should notify.success
        post :create, plan_create
        SyncPlan.first.should_not be_nil
        response.should be_success
      end

      it "should have a valid date" do
        controller.should notify.exception
        plan_create[:sync_plan].should_not be_nil
        data = plan_create
        data[:sync_plan][:plan_date] = '01/101/11'
        post :create, data
        SyncPlan.first.should be_nil
        response.should_not be_success
      end

      it "should have a unique name" do
        controller.should notify.exception
        SyncPlan.create!  :name => 'myplan', :interval => 'weekly', :sync_date => DateTime.now, :organization => controller.current_organization
        SyncPlan.first.should_not be_nil
        post :create, plan_create
        response.should_not be_success
      end

      it "should not have a nil name" do
        controller.should notify.exception
        data = plan_create
        data[:sync_plan][:name] = ''
        post :create, data
        SyncPlan.first.should be_nil
        response.should_not be_success
      end

      it_should_behave_like "bad request"  do
        let(:req) do
          bad_params = plan_create
          bad_params[:sync_plan][:bad_foo] = "gah"
          post :create, bad_params
        end
      end
    end

    describe "Delete a SyncPlan" do
      it "should delete a sync plan successfully" do
        plan = SyncPlan.create!  :name => 'myplan', :interval => 'weekly', :sync_date => DateTime.now, :organization => controller.current_organization
        controller.stub!(:render).and_return("") #ignore missing js partial
        SyncPlan.first.should_not be_nil
        controller.should notify.success
        delete :destroy, :id => plan.id
      end
    end

    describe "Update a SyncPlan" do
      before (:each) do
        @plan = SyncPlan.create! :name => 'myplan', :interval => 'weekly', :sync_date => DateTime.now, :organization => controller.current_organization
      end

      it "should update a sync plan name successfully" do
        SyncPlan.first.should_not be_nil
        controller.should notify.success
        put :update, :id => @plan.id, :sync_plan => {:name => 'yourplan'}
        response.should be_success
      end

      it "should update a sync plan interval successfully" do
        SyncPlan.first.should_not be_nil
        controller.should notify.success
        put :update, :id => @plan.id, :sync_plan => {:interval => 'daily'}
        response.should be_success
      end

      it "should update interval to none successfully" do
        SyncPlan.first.should_not be_nil
        controller.should notify.success
        put :update, :id => @plan.id, :sync_plan => {:interval => 'none'}
        response.should be_success
      end

      it "should update a sync plan description successfully" do
        SyncPlan.first.should_not be_nil
        controller.should notify.success
        put :update, :id => @plan.id, :sync_plan => {:description => 'Would rather be fishing then writing tests'}
        response.should be_success
      end

      it "should update a sync time description successfully" do
        SyncPlan.first.should_not be_nil
        controller.should notify.success
        put :update, :id => @plan.id, :sync_plan => {:time => '12:00 pm'}
        response.should be_success
      end

      it "should update a sync date description successfully" do
        SyncPlan.first.should_not be_nil
        controller.should notify.success
        put :update, :id => @plan.id, :sync_plan => {:date => '11/11/11'}
        response.should be_success
      end

      it "should not update bad sync dates" do
        SyncPlan.first.should_not be_nil
        controller.should notify.exception
        put :update, :id => @plan.id, :sync_plan => {:date => '11/111111/11'}
        response.should_not be_success
      end

      it "should not update bad sync time" do
        SyncPlan.first.should_not be_nil
        controller.should notify.exception
        put :update, :id => @plan.id, :sync_plan => {:time => '30:00 pmm'}
        response.should_not be_success
      end

      it "should not update a blank name" do
        SyncPlan.first.should_not be_nil
        controller.should notify.exception
        put :update, :id => @plan.id, :sync_plan => {:name => ''}
        response.should_not be_success
      end

      it_should_behave_like "bad request"  do
        let(:req) do
          bad_params =  {:id => @plan.id, :sync_plan => {:name => '122'}}
          bad_params[:sync_plan][:bad_foo] = "gah"
          post :create, bad_params
        end
      end


    end
  end
end
