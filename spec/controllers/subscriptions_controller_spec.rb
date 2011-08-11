require 'ostruct'
require 'spec_helper'

describe SubscriptionsController do

  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods




  describe "viewing subs" do
    before (:each) do
      login_user
      set_default_locale
      setup_current_organization(new_test_org)
      Candlepin::Owner.stub!(:pools).and_return([ProductTestData::POOLS])
      Candlepin::Owner.stub!(:statistics).and_return([])


      @product = OpenStruct.new
      @product.id = "testid"
      @product.support_level = "test_support_level"
      @product.arch = "noarch"
      @first = OpenStruct.new
      @first.first = @product
      Product.stub!(:where).and_return(@first)
    end

    it 'should show all subscriptions' do
      get :index
      response.should be_success
      response.should render_template("index")
      assigns[:subscriptions].should_not be_nil
    end

  end  

end
