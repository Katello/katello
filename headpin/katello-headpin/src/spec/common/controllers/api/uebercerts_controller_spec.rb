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
  OWNER_KEY = "some_org"

  let(:org) { Organization.new(:cp_key => OWNER_KEY) }
  before(:each) do
    login_user
    Organization.stub!(:first).and_return(org)
  end

  context "create" do
    before { Candlepin::Owner.stub!(:generate_ueber_cert).and_return({}) }

    it "should find organization" do
      Organization.should_receive(:first).once.and_return(org)
      post :create, :organization_id => OWNER_KEY
    end

    it "should call Uebercert create api" do
      Candlepin::Owner.should_receive(:generate_ueber_cert).once.with(OWNER_KEY).and_return({})
      post :create, :organization_id => OWNER_KEY
    end
  end

  context "show" do
    before { Candlepin::Owner.stub!(:get_ueber_cert).and_return({}) }

    it "should find organization" do
      Organization.should_receive(:first).once.and_return(org)
      post :show, :organization_id => OWNER_KEY
    end

    it "should call Uebercert create api" do
      Candlepin::Owner.should_receive(:get_ueber_cert).once.with(OWNER_KEY).and_return({})
      post :show, :organization_id => OWNER_KEY
    end
  end
end