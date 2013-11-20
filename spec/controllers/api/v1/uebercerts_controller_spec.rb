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
describe Api::V1::UebercertsController do
  include AuthorizationHelperMethods
  OWNER_KEY = "some_org"

  let(:org) { Organization.new(:label => OWNER_KEY) }
  before(:each) do
    setup_controller_defaults_api
    @controller.stubs(:get_organization).returns(org)
  end

  describe "rules" do
    let(:authorized_user) do
      user_with_permissions { |u| u.can(:read, :organizations, nil, @organization) }
    end
    let(:unauthorized_user) do
      user_without_permissions
    end
    describe "show" do
      let(:action) { :show }
      let(:req) do
        get :show, :organization_id => OWNER_KEY
      end
      it_should_behave_like "protected action"
    end
  end

  context "show" do
    before do
      Resources::Candlepin::Owner.stubs(:get_ueber_cert).returns({})
      disable_authorization_rules
    end

    it "should find organization" do
      @controller.expects(:find_organization)
      get :show, :organization_id => OWNER_KEY
    end

    it "should call Uebercert create api" do
      org.expects(:debug_cert).once.returns({})
      get :show, :organization_id => OWNER_KEY
    end
  end
end
end