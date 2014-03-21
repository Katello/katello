#
# Copyright 2014 Red Hat, Inc.
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

module Katello
  describe ActivationKeysController do

    include LocaleHelperMethods
    include OrganizationHelperMethods
    include AuthorizationHelperMethods
    include OrchestrationHelper

    before(:each) do
      setup_controller_defaults
      @organization = new_test_org

      @controller.stubs(:require_org).returns(true)
      @controller.stubs(:current_organization).returns(@organization)
    end

    describe "rules" do
      let(:action) {:index }
      let(:req) { get :index }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read_all, :activation_keys) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "GET index" do
      it "should be successful (katello)" do
        get :index
        must_respond_with(:success)
      end
    end

  end
end
