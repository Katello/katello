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
      @plan = SyncPlan.create!(:name => 'some plan_' + i.to_s,
                                  :sync_date => DateTime.now, :interval => 'daily',
                                    :organization => @org)
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

  describe "POST 'apply'" do
    it "should receive a notice" do
      controller.should_receive(:notice)
      plans = [SyncPlan.first.id.to_s]
      products = [Product.first.id.to_s]
      post 'apply', {:data => {:plans=> plans, :products=> products}.to_json}
    end
  end

end
