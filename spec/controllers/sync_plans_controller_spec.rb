require 'spec_helper'
require 'ruby-debug'

describe SyncPlansController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods

  before (:each) do
    login_user
    set_default_locale

    @org = new_test_org
    controller.stub!(:current_organization).and_return(@org)
  end
    let(:plan_create) do
      {
        :sync_plan => {
                       :name => 'myplan', 
                       :interval => 'weekly', 
                       :plan_date =>'01/01/11', 
                       :plan_time => '07:00 am', 
                       :description => 'RSPEC me' 
                      }
      }
    end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "Create a SyncPlan" do

    it "should create a plan successfully" do
      controller.should_receive(:notice)
      post :create, plan_create
      SyncPlan.first.should_not be_nil
      response.should be_success
    end

    it "should have a valid date" do
      controller.should_receive(:errors)
      plan_create[:sync_plan].should_not be_nil
      data = plan_create
      data[:sync_plan][:plan_date] = '01/101/11'
      post :create, data 
      SyncPlan.first.should be_nil
      response.should_not be_success
    end

    it "should have a unique name" do
      controller.should_receive(:errors)
      SyncPlan.create!  :name => 'myplan', :interval => 'weekly', :sync_date => DateTime.now, :organization => controller.current_organization 
      SyncPlan.first.should_not be_nil
      post :create, plan_create
      response.should_not be_success
    end

    it "should not have a nil name" do
      controller.should_receive(:errors)
      data = plan_create
      data[:sync_plan][:name] = ''
      post :create, data
      SyncPlan.first.should be_nil
      response.should_not be_success
    end

  end

  describe "Delete a SyncPlan" do
    it "should delete a sync plan successfully" do
      plan = SyncPlan.create!  :name => 'myplan', :interval => 'weekly', :sync_date => DateTime.now, :organization => controller.current_organization 
      controller.stub!(:render).and_return("") #ignore missing js partial
      SyncPlan.first.should_not be_nil
      controller.should_receive(:notice)
      delete :destroy, :id => plan.id
    end
  end

  describe "Update a SyncPlan" do
    before (:each) do
      @plan = SyncPlan.create! :name => 'myplan', :interval => 'weekly', :sync_date => DateTime.now, :organization => controller.current_organization
    end

    it "should update a sync plan name successfully" do
      SyncPlan.first.should_not be_nil
      controller.should_receive(:notice)
      put :update, :id => @plan.id, :plan => {:name => 'yourplan'}
      response.should be_success
    end

    it "should update a sync plan interval successfully" do
      SyncPlan.first.should_not be_nil
      controller.should_receive(:notice)
      put :update, :id => @plan.id, :plan => {:interval => 'daily'}
      response.should be_success
    end

    it "should update a sync plan description successfully" do
      SyncPlan.first.should_not be_nil
      controller.should_receive(:notice)
      put :update, :id => @plan.id, :plan => {:description => 'Would rather be fishing then writing tests'}
      response.should be_success
    end

    it "should update a sync time description successfully" do
      SyncPlan.first.should_not be_nil
      controller.should_receive(:notice)
      put :update, :id => @plan.id, :plan => {:time => '12:00 pm'}
      response.should be_success
    end

    it "should update a sync date description successfully" do
      SyncPlan.first.should_not be_nil
      controller.should_receive(:notice)
      put :update, :id => @plan.id, :plan => {:date => '11/11/11'}
      response.should be_success
    end

    it "should not update bad sync dates" do
      SyncPlan.first.should_not be_nil
      controller.should_receive(:errors)
      put :update, :id => @plan.id, :plan => {:date => '11/111111/11'}
      response.should_not be_success
    end

    it "should not update bad sync time" do
      SyncPlan.first.should_not be_nil
      controller.should_receive(:errors)
      put :update, :id => @plan.id, :plan => {:time => '30:00 pmm'}
      response.should_not be_success
    end

    it "should not update a blank name" do
      SyncPlan.first.should_not be_nil
      controller.should_receive(:errors)
      put :update, :id => @plan.id, :plan => {:name => ''}
      response.should_not be_success
    end
  end

end
