
require 'spec_helper'
require 'controllers/subscriptions_controller_data'

describe SubscriptionsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  include SubscriptionsControllerData

  # TODO: consumers tab w/ limited access to systems
  # TODO: check locale strings

  # TODO: "GET index"
  # TODO:   "role based access control"
  # TODO:     "without org access"
  # TODO:     "read org access"
  # TODO:     "edit org access"
  # TODO:   "before a manifest is imported"
  # TODO:   "without any subscriptions"
  # TODO:   "after last manifest import had an error"
  # TODO:   "with subscriptions"

  describe "GET index" do
    before (:each) do
      @organization = new_test_org
      setup_current_organization(@organization)
      set_default_locale
      @provider = @organization.redhat_provider

      # Users to use for role based access control
      @disallowed_user = user_without_permissions
      @read_user = user_with_permissions { |u| u.can(:read, :organizations, nil, @organization)}
      @update_user = user_with_permissions { |u| u.can(:update, :organizations, nil, @organization)}
    end

    describe "before a manifest is imported" do
      before (:each) do
        # No import history from candlepin means no manifest upload ever attempted, and no async tasks
        Resources::Candlepin::Owner.stub!(:imports).and_return([])
        Provider.stub!(:task_status).and_return(nil)
      end

      it "should open new panel for user with update permissions" do
        login_user({:user=>@update_user})
        get :index
        response.should be_success
        response.should render_template("index")
        assigns[:panel_options][:initial_state].should == {"panel" => :new}
      end

      it "should not open new panel for user with read permissions" do
        login_user({:user=>@read_user})
        get :index
        response.should be_success
        response.should render_template("index")
        assigns[:panel_options][:initial_state].should_not == {"panel" => :new}
      end

      it "should 403 for user with no permissions" do
        login_user({:user=>@disallowed_user})
        get :index
        response.status.should == 403
      end
    end

    describe "after the most recent manifest import failed" do
      before (:each) do
        # No import history from candlepin means no manifest upload ever attempted, and no async tasks
        #Resources::Candlepin::Owner.stub!(:get).and_return('[{"updated" : "2012-05-29T14:52:45.648+0000", "status" : "SUCCESS"}, {"updated" : "2012-05-30T14:45:13.522+0000", "status" : "FAILURE"}]')
        candlepin_owner_imports :manifest_upload_failure
        Provider.stub!(:task_status).and_return(nil)
      end

      it "should open new panel for user with update permissions" do
        login_user({:user=>@update_user})
        get :index
        response.should be_success
        response.should render_template("index")
        assigns[:panel_options][:initial_state].should == {"panel" => :new}
      end
    end
  end
end
