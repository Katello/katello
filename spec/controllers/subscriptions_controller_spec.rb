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
        # No upstreamUuid in owner details means no manifest is loaded, and no async tasks
        Resources::Candlepin::Owner.stub!(:find).and_return({})
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
        # No upstreamUuid in owner details means no manifest is loaded, and no async tasks
        Resources::Candlepin::Owner.stub!(:find).and_return({})
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
