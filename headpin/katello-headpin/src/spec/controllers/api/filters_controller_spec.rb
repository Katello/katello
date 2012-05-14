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
include OrchestrationHelper

describe Api::FiltersController, :katello => true do
  include LoginHelperMethods
  include LocaleHelperMethods
  include AuthorizationHelperMethods

  let(:pulp_id) { "FILTER1" }
  let(:description) { "DESCRIPTION" }
  let(:package_list) { "package1, package2" }
  let(:product_id) { 1000 }

  before (:each) do
    login_user
    set_default_locale
    disable_org_orchestration
    disable_filter_orchestration
    disable_product_orchestration

    @organization = Organization.create!(:name => 'test_org', :cp_key => 'test_org')
    @filter = Filter.create!(:name => pulp_id, :description => description, :package_list => package_list, :organization => @organization)
    @product = MemoStruct.new(:filters => [], :id => 1000)
  end

  context "create filter" do
    before(:each) do
      Filter.stub!(:create!).and_return({})
    end

    it "should find organization" do
      post :create, :organization_id => @organization.cp_key, :name => pulp_id, :description => description, :package_list => package_list
      assigns(:organization).should == @organization
    end

    it "should create a filter" do
      Filter.should_receive(:create!).once.with(hash_including(
          :name => pulp_id,
          :organization => @organization,
          :description => description,
          :package_list => package_list)).and_return({})

      post :create, :organization_id => @organization.cp_key, :name => pulp_id, :description => description, :package_list => package_list
    end

    it_should_behave_like "bad request"  do
      let(:req) do
        post :create, :bad_foo => "ss", :organization_id => @organization.cp_key, :name => pulp_id, :description => description, :package_list => package_list
      end
    end

  end

  context "list filters" do
    it "should find organization" do
      get :index, :organization_id => @organization.cp_key
      assigns(:organization).should == @organization
    end
  end

  context "show filter" do
    it "should find filter" do
      get :show, :organization_id => @organization.cp_key, :id => @filter.name
      assigns(:filter).should == @filter
    end
  end

  context "delete filter" do
    it "should find filter" do
      delete :destroy, :organization_id => @organization.cp_key, :id => @filter.name
      assigns(:filter).should == @filter
    end

    it "should delete filter" do
      delete :destroy, :organization_id => @organization.cp_key, :id => @filter.name
      Filter.where(:id => @filter.id).should be_empty
    end
  end

  context "update filter" do
    before(:each) do
      Product.stub!(:find_by_cp_id).and_return(@product)
      Filter.stub!(:where).and_return([@filter])
    end

    it "should find product" do
      Product.should_receive(:find_by_cp_id).once.with(product_id).and_return(@product)
      put :update_product_filters, :organization_id => @organization.cp_key, :product_id => product_id, :filters => []
    end

    it "should find filters" do
      Filter.should_receive(:where).once.with(hash_including(:name => [@filter.name], :organization_id => @organization.id))
      put :update_product_filters, :organization_id => @organization.cp_key, :product_id => product_id, :filters => [@filter.name]
    end

    it "should add new filter" do
      put :update_product_filters, :organization_id => @organization.cp_key, :product_id => product_id, :filters => [@filter.name]
      assigns(:product).filters.size.should == 1
      assigns(:product).filters.should include(@filter)
    end
  end


end
