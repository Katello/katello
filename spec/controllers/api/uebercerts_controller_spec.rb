#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'spec_helper.rb'

describe Api::UebercertsController do
  include LoginHelperMethods
  include AuthorizationHelperMethods
  include LocaleHelperMethods
  OWNER_KEY = "some_org"

  let(:org) { Organization.new(:label => OWNER_KEY) }
  before(:each) do
    login_user
    set_default_locale
    Organization.should_receive(:without_deleting).at_least(:once).and_return(Organization)
    Organization.stub!(:where).and_return(Organization)
    Organization.stub!(:first).and_return(org)
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
        post :show, :organization_id => OWNER_KEY
      end
      it_should_behave_like "protected action"
    end
  end

  context "show" do
    before do
      Resources::Candlepin::Owner.stub!(:get_ueber_cert).and_return({})
      disable_authorization_rules
    end

    it "should find organization" do
      Organization.should_receive(:where).once.and_return(Organization)
      Organization.stub!(:first).and_return(org)
      post :show, :organization_id => OWNER_KEY
    end

    it "should call Uebercert create api" do
      org.should_receive(:debug_cert).once.and_return({})
      post :show, :organization_id => OWNER_KEY
    end
  end
end
