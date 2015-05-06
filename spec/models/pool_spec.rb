require 'katello_test_helper'
require 'helpers/product_test_data'

module Katello
  describe Pool do
    include OrchestrationHelper

    describe "Find pool by organization and id" do
      let(:pool_id) { ProductTestData::POOLS[:id] }
      before do
        Resources::Candlepin::Pool.expects(:find).with(pool_id).returns(ProductTestData::POOLS)
      end
      it "should return pool that is in the organization" do
        create_org_from_cp_owner(ProductTestData::POOLS[:owner])
        Pool.find_by_organization_and_id(@organization, pool_id).cp_id.must_equal(ProductTestData::POOLS[:id])
      end

      it "should return nil if the pool doesn't belong to the organization" do
        create_org_from_cp_owner(:displayName => "Another Org", :key => "another_org")
        Pool.find_by_organization_and_id(@organization, pool_id).must_be_nil
      end
    end

    def create_org_from_cp_owner(cp_owner)
      disable_org_orchestration
      @organization = Organization.create!(:name => cp_owner[:displayName], :label => "pool_org", :label => cp_owner[:key])
    end
  end
end
