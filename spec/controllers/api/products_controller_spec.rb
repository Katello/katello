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

describe Api::ProductsController do
  include LoginHelperMethods

  let(:products) do
    [{
      :name => 'a_product',
      :id => 'id',
      :multiplier => 1
    }]
  end
  let(:organization_id) { 'organization' }
  let(:environment_id) { '1' }
  let(:product_id) { '1234' }
  let(:repositories) do
    [
        { :id => 1 },
        { :id => 2 }
    ]
  end

  before (:each) do
    @organization = Organization.new
    @organization.id = 1

    @environment = KPEnvironment.new
    @locker = KPEnvironment.new

    @organization.locker = @locker
    @organization.environments << @environment

    products.stub(:where).and_return(products)
    
    @product = products[0]
    Product.stub!(:find_by_cp_id).and_return(@product)
    Product.stub!(:find).and_return(@product)
    @product.stub(:repos).and_return(repositories)
    
    Organization.stub!(:first).and_return(@organization)
    KPEnvironment.stub!(:first).and_return(@environment)

    Organization.stub!(:find).and_return(@organization)
    KPEnvironment.stub!(:find).and_return(@environment)
    
    @organization.stub!(:locker).and_return(@locker)

    @environment.stub!(:products).and_return(products)
    @locker.stub!(:products).and_return(products)



    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
  end

  context "show all products in an environment" do
    it "should find organization" do
      Organization.should_receive(:first).once.with({:conditions => {:cp_key => organization_id}}).and_return(@organization)
      get 'index', :organization_id => organization_id
    end

    it "should find environment" do
      KPEnvironment.should_receive(:find).once.with(environment_id).and_return([@environment])
      get 'index', :organization_id => organization_id, :environment_id => environment_id
    end

    it "should respond with success" do
      get 'index', :organization_id => organization_id, :environment_id => environment_id
      response.should be_success
    end

    it "should respond return product json" do
      get 'index', :organization_id => organization_id, :environment_id => environment_id
      response.body.should == products.to_json
    end
  end

  context "show all products in locker" do
    it "should find organization" do
      Organization.should_receive(:first).once.with({:conditions => {:cp_key => organization_id}}).and_return(@organization)
      get 'index', :organization_id => organization_id
    end

    it "should find locker" do
      @organization.should_receive(:locker).once.and_return(@locker)
      get 'index', :organization_id => organization_id
    end

    it "should respond with success" do
      get 'index', :organization_id => organization_id, :environment_id => environment_id
      response.should be_success
    end

    it "should respond return product json" do
      get 'index', :organization_id => organization_id, :environment_id => environment_id
      response.body.should == products.to_json
    end
  end

  context "show repositories for a product in an environment" do

    it "should find environment" do
      KPEnvironment.should_receive(:find).once.with(environment_id).and_return([@environment])
      get 'repositories', :organization_id => organization_id, :environment_id => environment_id, :id => product_id
    end

    it "should find product" do
      Product.should_receive(:find_by_cp_id).once.with(product_id).and_return(products[0])
      get 'repositories', :organization_id => organization_id, :environment_id => environment_id, :id => product_id
    end

    it "should retrieve all repositories for the product" do
      @product.should_receive(:repos).once.with(@environment).and_return({})
      get 'repositories', :organization_id => organization_id, :environment_id => environment_id, :id => product_id
    end

    it "should return json of product repositories" do
      get 'repositories', :organization_id => organization_id, :environment_id => environment_id, :id => product_id
      response.body.should == repositories.to_json
    end
  end

end