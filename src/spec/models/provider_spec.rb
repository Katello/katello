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
include OrchestrationHelper

describe Provider do

  let(:to_create_rh) do
    {
      :name => "some name",
      :description => "a description",
      :repository_url => "https://some.url",
      :provider_type => Provider::REDHAT,
      :organization => @organization
    }
  end

  let(:to_create_custom) do
    {
      :name => "some name",
      :description => "a description",
      :repository_url => "https://some.url/path",
      :provider_type => Provider::CUSTOM
    }
  end

  before(:each) do
    disable_org_orchestretion
    disable_product_orchestration
    @organization = Organization.new(:name =>"org10020", :cp_key => 'org10020')
    @organization.save!
  end

  context "set_product creates product with correct attributes" do
    before(:each) do
      Glue::Candlepin::ProductContent.stub(:create)
      Glue::Candlepin::ProductContent.stub(:new)
      Candlepin::Product.stub!(:create).and_return({:id => "product_id"})
      @provider = Provider.new({
        :name => 'test_provider',
        :repository_url => 'https://something',
        :provider_type => Provider::REDHAT,
        :organization => @organization
      })
      @provider.save!

      @provider.set_product({:name=> "prod", :productContent => []})
      @product = Product.first(:conditions => {:cp_id => "product_id" })
    end

    specify { @product.should_not be_nil }
    specify { @product.provider.should == @provider }
    specify { @product.environments.should include(@organization.locker) }
    specify { @organization.locker.products.should include(@product) }
  end

  context "queue_pool_product_creation" do
    before(:each) do
      @provider = Provider.new(:organization => @organization)
      @product_to_return = {}
    end

    it "should make correct calls" do
      Candlepin::Owner.should_receive(:pools).once.and_return([
        { :productId => "1",  :providedProducts => [{ :productId => "3" }, { :productId => "4" }] },
        { :productId => "2" }
      ])

      Candlepin::Product.should_receive(:get).once.with("1").and_return([@product_to_return])
      Candlepin::Product.should_receive(:get).once.with("2").and_return([@product_to_return])
      Candlepin::Product.should_receive(:get).once.with("3").and_return([@product_to_return])
      Candlepin::Product.should_receive(:get).once.with("4").and_return([@product_to_return])

      @provider.should_receive(:queue_create_product).exactly(4).times.with(@product_to_return)
      @provider.should_receive(:process).once

      @provider.queue_pool_product_creation
    end
  end

  context "import manifest via RED HAT provider" do
    before(:each) do
      @organization = Organization.new(:name =>"org10020", :cp_key => "org10020_key")
      @provider = Provider.create(to_create_rh)
    end

    it "should make correct calls" do
      Candlepin::Owner.should_receive(:import).once.with(@organization.cp_key, "path_to_manifest").and_return(true)
      @provider.should_receive(:queue_pool_product_creation).once.and_return(true)

      @provider.import_manifest "path_to_manifest"
    end
  end

  context "sync provider" do
    before(:each) do
      @provider = Provider.create(to_create_custom) do |p|
        p.organization = @organization
      end
      @provider.set_product({ :name => "product1", :id => "product1_id", :productContent => [] })
      @provider.set_product({ :name => "product2", :id => "product2_id", :productContent => [] })
    end
    
    it "should create sync for all it's products" do
      @provider.products.each do |p|
        p.should_receive(:sync).once()
      end
      @provider.sync
    end
  end
  
  context "Provider in invalid state should not pass validation" do
    before(:each) { @provider = Provider.new }

    it "should be invalid without repository type" do
      @provider.name = "some name"
      @provider.repository_url = "https://some.url.here"

      @provider.should_not be_valid
      @provider.errors[:provider_type].should_not be_empty
    end

    it "should be invalid without name" do
      @provider.repository_url = "https://some.url.here"
      @provider.provider_type = Provider::REDHAT

      @provider.should_not be_valid
      @provider.errors[:name].should_not be_empty
    end

    it "should be invalid without url" do
      @provider.name = "some name"
      @provider.provider_type = Provider::REDHAT

      @provider.should_not be_valid
      @provider.errors[:repository_url].should_not be_empty
    end

    it "shouldn't care about invalid url for custom provider" do
      @provider.name = "url test"
      @provider.provider_type = Provider::CUSTOM
      @provider.repository_url = "notavalidurl"
      @provider.should be_valid
    end

    it "should handle invalid urls for RH provider" do
      @provider.name = "url test"
      @provider.provider_type = Provider::REDHAT
      @provider.repository_url = "notavalidurl"
      @provider.should_not be_valid
    end
    
    it "should be invalid to create two providers with the same name" do
      @provider.name = "some name"
      @provider.repository_url = "https://some.url.here"
      @provider.provider_type = Provider::REDHAT
      @provider.save!
      
      @provider2 = Provider.new
      @provider2.name = "some name"
      @provider2.repository_url = "https://some.url.here"
      @provider2.provider_type = Provider::REDHAT
      
      @provider2.should_not be_valid
      @provider2.errors[:name].should_not be_empty
    end
  end

  context "Provider in valid state" do

    it "should be valid for RH provider" do
      @provider = Provider.create(to_create_rh)
      @provider.should be_valid
      @provider.errors[:repository_url].should be_empty
    end

    it "should be valid for Custom provider" do
      @provider = Provider.create(to_create_custom)
      @provider.should be_valid
      @provider.errors[:repository_url].should be_empty
    end
    
  end
  
  context "Delete a provider" do
    
    it "should delete the RH provider" do
      @provider = Provider.create(to_create_rh)
      id = @provider.id
      @provider.destroy
      lambda{Provider.find(id)}.should raise_error(ActiveRecord::RecordNotFound)
    end
    
    it "should delete the Custom provider" do
      @provider = Provider.create(to_create_rh)
      id = @provider.id
      @provider.destroy
      lambda{Provider.find(id)}.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
  
end
