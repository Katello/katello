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

describe UserSessionsController do

  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper
  include LoginHelperMethods

    before(:each) do
      set_default_locale
    end

  describe "select organization" do

    before(:each) do
      disable_user_orchestration

      @user = User.new
      @user.username = "shaggy"
      @user.password = "norville"
      @user.email = 'shaggy@somewhere.com'
      @user.save

      login_user :mock => false, :user => @user
    end

    it "should have valid org selected" do
      org = new_test_org
      allow(@user.own_role, [:read], :providers, nil, org)
      post :set_org, {:org_id => org.id }
      response.should redirect_to(dashboard_index_url)
    end

    it "should not have valid org selected" do
      controller.should notify.error
      org = new_test_org
      post :set_org, {:org_id => org.id }
    end

  end

end
