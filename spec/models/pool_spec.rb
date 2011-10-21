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

require 'spec_helper'

describe KTPool do

  context "Find pool by organization and id" do
    it "should return pool that is in the organization" do
      @pool_id = ProductTestData::POOLS[:id]
      disable_org_orchestration
      cp_owner = ProductTestData::POOLS[:owner]
      @organization = Organization.create!(:name => cp_owner[:displayName], :cp_key => cp_owner[:key])
      Candlepin::Pool.should_receive(:get).with(@pool_id).and_return(ProductTestData::POOLS)
      KTPool.find_by_organization_and_id(@organization, @pool_id).cp_id.should == ProductTestData::POOLS[:id]
    end

    it "should return nil if the pool doesn't belong to the organization" do
      @pool_id = ProductTestData::POOLS[:id]
      disable_org_orchestration
      cp_owner = { :displayName => "Another Org", :key => "another_org" }
      @organization = Organization.create!(:name => cp_owner[:displayName], :cp_key => cp_owner[:key])
      Candlepin::Pool.should_receive(:get).with(@pool_id).and_return(ProductTestData::POOLS)
      KTPool.find_by_organization_and_id(@organization, @pool_id).should be_nil
    end
  end

end
