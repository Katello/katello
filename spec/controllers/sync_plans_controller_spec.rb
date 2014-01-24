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

module Katello
describe SyncPlansController do

  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  describe "(katello)" do

  describe "rules" do
    before (:each) do
      new_test_org
      setup_controller_defaults
    end
    describe "GET index" do
      before do
        @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@organization)
      end
      let(:action) {:index}
      let(:req) { get :index}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :providers, @provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
  end

  describe "other-tests" do
    before (:each) do
      setup_controller_defaults
      @controller.stubs(:current_organization).returns(new_test_org)
    end

    describe "GET 'index'" do
      it "should be successful" do
        get :index
        must_respond_with(:success)
        must_render_template("bastion/layouts/application")
      end
    end

  end
  end
end
end
