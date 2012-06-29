
require 'spec_helper'

describe SubscriptionsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  # TODO: consumers tab w/ limited access to systems
  # TODO: check locale strings

  # TODO: "GET index"
  # TODO:   "role based access control"
  # TODO:     "without provider access"
  # TODO:     "read provider access"
  # TODO:     "edit provider access"
  # TODO:   "before a manifest is imported"
  # TODO:   "without any subscriptions"
  # TODO:   "after last manifest import had an error"
  # TODO:   "with subscriptions"

  describe "GET index" do
    before do
      @organization = new_test_org
      setup_current_organization(@organization)
      set_default_locale
      @provider = @organization.redhat_provider

      # Users to use for role based access control
      @disallowed_user = user_without_permissions
      @readonly_user = user_with_permissions { |u| u.can(:read, :organizations, nil, @organization)}
      @edit_user = user_with_permissions { |u| u.can(:update, :organizations, nil, @organization)}

      # Don't enter elastic search'
      Tire.stub(:index)
    end

    describe "before a manifest is imported" do
      before do
        # No import history from candlepin means no manifest upload ever attempted
        Resources::Candlepin::Owner.stub!(:imports).and_return([])

        login_user({:user=>@edit_user})
      end

      it "should open new panel" do
        Provider.stub!(:task_status).and_return(nil)
        get :index
        response.should be_success
        response.should render_template("index")
        #assigns[:panel_options].should include(:initial_state)
        assigns[:panel_options][:initial_state].should == {"panel" => :new}
      end
    end
  end

=begin
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  describe "rules" do
    before (:each) do
      new_test_org
      Organization.stub!(:first).with(:conditions => {:cp_key=>@organization.cp_key}).and_return(@organization)
    end
    describe "GET index" do
      let(:action) {:index}
      let(:req) { get :index}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :organizations,nil, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
  end

  describe "viewing subs" do
    before (:each) do
      login_user
      set_default_locale
      setup_current_organization(new_test_org)
      Resources::Candlepin::Owner.stub!(:pools).and_return([ProductTestData::POOLS])
      Resources::Candlepin::Owner.stub!(:statistics).and_return([])


      @product = MemoStruct.new
      @product.id = "testid"
      @product.support_level = "test_support_level"
      @product.arch = "noarch"
      @first = MemoStruct.new
      @first.first = @product
      Product.stub!(:where).and_return(@first)
      Tire.stub(:index)
    end

    it 'should show all subscriptions' do
      Resources::Candlepin::Owner.stub!(:imports).and_return([])
      Provider.stub!(:task_status).and_return(nil)
      get :index
      response.should be_success
      response.should render_template("index")
      assigns[:subscriptions].should_not be_nil
    end

  end
=end

end
