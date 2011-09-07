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
require 'helpers/product_test_data'

include OrchestrationHelper

describe Product do

  before(:each) do
    disable_org_orchestration

    @organization = Organization.create!(:name => ProductTestData::ORG_ID, :cp_key => 'admin-org-37070')
    @provider     = Provider.create!({:organization => @organization, :name => 'provider', :repository_url => "https://something.url", :provider_type => Provider::REDHAT})

    ProductTestData::SIMPLE_PRODUCT.merge!({:provider => @provider, :environments => [@organization.locker]})
    ProductTestData::SIMPLE_PRODUCT_WITH_INVALID_NAME.merge!({:provider => @provider, :environments => [@organization.locker]})
    ProductTestData::PRODUCT_WITH_ATTRS.merge!({:provider => @provider, :environments => [@organization.locker]})
    ProductTestData::PRODUCT_WITH_CONTENT.merge!({:provider => @provider, :environments => [@organization.locker]})
  end

  describe "create product" do

    context "new product" do
      before(:each) { @p = Product.new({}) }
      specify { @p.productContent.should == [] }
    end

    context "with valid parameters" do
      before(:each) do
        disable_product_orchestration
        @p = Product.create!(ProductTestData::SIMPLE_PRODUCT)
      end

      specify { @p.name.should == ProductTestData::SIMPLE_PRODUCT['name'] }
      specify { @p.created_at.should_not be_nil }
      specify { @p.environments.should include(@organization.locker) }
    end

    context "candlepin orchestration" do
      before do
        Candlepin::Product.stub!(:certificate).and_return("")
        Candlepin::Product.stub!(:key).and_return("")
        Pulp::Repository.stub!(:create).and_return([])
      end

      context "with attributes" do
        it "should create product in katello" do

          expected_product = {
              :attributes => ProductTestData::PRODUCT_WITH_ATTRS[:attributes],
              :multiplier => ProductTestData::PRODUCT_WITH_ATTRS[:multiplier],
              :name => ProductTestData::PRODUCT_WITH_ATTRS[:name]
          }

          Candlepin::Product.should_receive(:create).once.with(hash_including(expected_product)).and_return({:id => 1})
          product = Product.create!(ProductTestData::PRODUCT_WITH_ATTRS)
          product.organization.should_not be_nil
        end
      end

      context "with content" do
        it "should create product in katello" do
          expected_content = ProductTestData::PRODUCT_WITH_CONTENT[:productContent][0].content

          Candlepin::Product.stub!(:create).and_return({:id => ProductTestData::PRODUCT_ID})
          Candlepin::Content.should_receive(:create)                \
              .once.with(an_instance_of(Glue::Candlepin::Content))  \
              .and_return({:id => ProductTestData::PRODUCT_WITH_CONTENT[:productContent][0].content.id})
                # don't know how to verify equality
              #c.name == 'aa' #expected_content[:name]
              #c.id = expected_content[:id]
              #c.type = expected_content[:type]
              #c.label = expected_content[:label]
              #c.vendor = expected_content[:vendor]
              #c.contentUrl = expected_content[:contentUrl]
              #c.gpgUrl = expected_content[:gpgUrl]
          Candlepin::Product.
              should_receive(:add_content).once.
              with(
                ProductTestData::PRODUCT_ID,
                ProductTestData::PRODUCT_WITH_CONTENT[:productContent][0].content.id,
                ProductTestData::PRODUCT_WITH_CONTENT[:productContent][0].enabled
              ).and_return({})

          p = Product.create!(ProductTestData::PRODUCT_WITH_CONTENT)
        end
      end

    end
  end

  context "lazily-loaded attributes" do
    before(:each) do
      Candlepin::Product.stub!(:get).and_return([ProductTestData::SIMPLE_PRODUCT.merge(:attributes => [])])
      Candlepin::Product.stub!(:create).and_return({:id => ProductTestData::PRODUCT_ID})
      @p = Product.create!({
        :name => ProductTestData::PRODUCT_NAME,
        :id => ProductTestData::PRODUCT_ID,
        :productContent => [],
        :provider => @provider,
        :environments => [@organization.locker]
      })
    end

    it "should retrieve Product from candlepin" do
      Candlepin::Product.should_receive(:get).once.with(ProductTestData::PRODUCT_ID).and_return([ProductTestData::SIMPLE_PRODUCT])
      @p.multiplier
    end

    it "should initialize lazily-loaded attributes" do
      @p.multiplier.should == ProductTestData::SIMPLE_PRODUCT[:multiplier]
    end

    it "should replace 'attributes' with 'attrs'" do
      Candlepin::Product.stub!(:get).and_return([ProductTestData::SIMPLE_PRODUCT.merge(:attributes => [{:name => 'blah'}])])
      @p.attrs.should_not be_nil
    end

    context "arch attribute" do
      it "should be no_arch if arch attribute is not present" do
        @p.arch.should == @p.default_arch
      end

      it "should have the value of 'arch' attribute" do
        Candlepin::Product.stub!(:get).and_return([ProductTestData::SIMPLE_PRODUCT.merge(:attributes => [{:name => 'arch', :value => 'i386'}])])
        @p.arch.should == 'i386'
      end
    end

    it "should receive valid certificate" do
      Candlepin::Product.stub!(:certificate).and_return("---SOME CERT---")
      @p.certificate.should == "---SOME CERT---"
    end

    it "should receive valid key from candlepin" do
      Candlepin::Product.stub!(:key).and_return("---SOME KEY---")
      @p.key.should == "---SOME KEY---"
    end
  end

  context "validation" do
    before(:each) do
      disable_product_orchestration
    end

    specify { Product.new(:name => 'contains /', :environments => [@organization.locker], :provider => @provider).should_not be_valid }
    specify { Product.new(:name => 'contains #', :environments => [@organization.locker], :provider => @provider).should_not be_valid }
    specify { Product.new(:name => 'contains space', :environments => [@organization.locker], :provider => @provider).should be_valid }

    it "should throw an exception when creating a product with duplicate name in one organization" do
      @p = Product.create!(ProductTestData::SIMPLE_PRODUCT)

      Product.new({
        :name => @p.name,
        :id => @p.cp_id,
        :productContent => @p.productContent,
        :provider => @p.provider,
        :environments => @p.environments
      }).should_not be_valid
    end
  end

  context "product repos" do
    before(:each) do
      disable_product_orchestration
      Candlepin::Product.stub!(:create).and_return({:id => ProductTestData::PRODUCT_ID})
      @p = Product.create!(ProductTestData::SIMPLE_PRODUCT)
    end

    context "repo id" do
      it "should start with product id" do
        @p.repo_id('123').index("#{ProductTestData::PRODUCT_ID}").should == 0
      end

      it "should end with organization id" do
        @p.repo_id('123').index("#{ProductTestData::ORG_ID}").should == @p.repo_id('123').length - "#{ProductTestData::ORG_ID}".length
      end

      it "should have environment name in it if one was specified" do
        @p.repo_id('123', 'root').should == "#{ProductTestData::PRODUCT_ID}-123-root-#{ProductTestData::ORG_ID}"
      end

      it "should be the same as content id for cloned repository" do
        @p.repo_id("#{ProductTestData::PRODUCT_ID}-123-root-#{ProductTestData::ORG_ID}").should == "#{ProductTestData::PRODUCT_ID}-123-root-#{ProductTestData::ORG_ID}"
      end
    end

    describe "add repo" do
      context "when there is a repo with the same name for the product" do
        before do
          @repo_name = "repo"
        end

        it "should raise conflict error" do
          @p.should_receive(:repos).with(@p.locker, {:name => "repo"}).and_return([Glue::Pulp::Repo.new(:id => "123")])
          lambda { @p.add_new_content("repo", "http://test/repo","yum") }.should raise_error(Errors::ConflictException)
        end
      end

    end
  end

end
