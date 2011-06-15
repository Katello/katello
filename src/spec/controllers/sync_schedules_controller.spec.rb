require 'spec_helper'

describe SyncSchedulesController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include ProductHelperMethods
  include OrchestrationHelper


  before (:each) do
    login_user
    set_default_locale

    @org = new_test_org
    for i in 1..10
      @plan = SyncPlan.create!({:name => 'some plan_' + i.to_s, :organization => @org})
    end
    @p = new_test_product_with_locker(@org)
    controller.stub!(:current_organization).and_return(@org)
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

  describe "POST 'apply_schedules'" do
    it "should recieve a notice" do
      controller.should_receive(:notice)
      plans = [SyncPlan.first.id.to_s]
      products = [Product.first.id.to_s]
      post 'apply_schedules', {:selected_items => {:plans=> plans, :products=> products}}
    end
  end

end
