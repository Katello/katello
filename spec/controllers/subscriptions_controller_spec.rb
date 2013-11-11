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
require 'controllers/subscriptions_controller_data'

module Katello
describe SubscriptionsController do

  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  include SubscriptionsControllerData

  describe "GET index" do
    before (:each) do
      @organization = new_test_org
      @controller.stubs(:current_organization).returns(@organization)
      setup_controller_defaults
      @provider = @organization.redhat_provider
    end

    describe "before a manifest is imported" do
      before (:each) do
        # No upstreamUuid in owner details means no manifest is loaded, and no async tasks
        Resources::Candlepin::Owner.stubs(:find).returns({})
        Provider.stubs(:task_status).returns(nil)
      end

      it "should open new panel for user with update permissions" do
        setup_controller_defaults
        get :index
        must_respond_with(:success)
        must_render_template("index")
        assigns[:panel_options][:initial_state].must_equal({"panel" => :new})
      end

      it "should not open new panel for user with read permissions" do
        @read_user = user_with_permissions { |u| u.can(:read, :organizations, nil, @organization)}
        set_user(@read_user)
        get :index
        must_respond_with(:success)
        must_render_template("index")
        assigns[:panel_options][:initial_state].wont_equal({"panel" => :new})
      end

      it "should 403 for user with no permissions" do
        @disallowed_user = user_without_permissions
        set_user(@disallowed_user)
        get :index
        must_respond_with(403)
      end
    end
=begin
    describe "after the most recent manifest import failed" do
      before (:each) do
        # No upstreamUuid in owner details means no manifest is loaded, and no async tasks
        Resources::Candlepin::Owner.stubs(:find).returns({})
        candlepin_owner_imports :manifest_upload_failure
        Provider.stubs(:task_status).returns(nil)
      end

      it "should open new panel for user with update permissions" do
        get :index
        must_respond_with(:success)
        must_render_template("index")
        assigns[:panel_options][:initial_state].must_equal({"panel" => :new})
      end
    end
=end
  end
end
end
