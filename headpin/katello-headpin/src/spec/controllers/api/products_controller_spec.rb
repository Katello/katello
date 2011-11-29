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

describe Api::ProductsController, :katello => true do
  include LoginHelperMethods
  include AuthorizationHelperMethods
  include ProductHelperMethods
  let(:user_with_read_permissions) { user_with_permissions { |u| u.can([:read], :providers, @provider.id, @organization) } }
  let(:user_without_read_permissions) { user_without_permissions }

  before (:each) do
    disable_org_orchestration
    disable_product_orchestration
    disable_user_orchestration

    @organization = new_test_org
    @environment = KTEnvironment.create!(:name=> "foo123", :organization => @organization, :prior =>@organization.locker)
    @provider = Provider.create!(:name => "provider", :provider_type => Provider::CUSTOM,
                                 :organization => @organization, :repository_url => "https://something.url/stuff")
    @product = Product.new({:name => "prod"})

    @product.provider = @provider
    @product.environments << @organization.locker
    @product.stub(:arch).and_return('noarch')
    @product.save!
    ep_locker = EnvironmentProduct.find_or_create(@organization.locker, @product)
    @repo_locker= Repository.create!(:environment_product => ep_locker, :name=> "repo", :pulp_id=>"2",:enabled => true)
    @repo = promote(@repo_locker, @environment)


    @products = [@product]
    @repositories = [@repo]

    @product = @products[0]

    Product.stub!(:find_by_cp_id).and_return(@product)
    Product.stub!(:find).and_return(@product)

    Product.stub!(:select).and_return(@products)
    @product.stub(:repos).and_return(@repositories)
    @product.stub(:sync_state => ::PulpSyncStatus::Status::NOT_SYNCED)
    Pulp::Repository.stub(:sync_history => [])


    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
  end

  context "show all @products in an environment" do

    let(:action) { :index }
    let(:req) { get 'index', :organization_id => @organization.cp_key }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    before do
      @dumb_prod = {:id => @product.id}
      Product.stub!(:all_readable).and_return(@products)
      @products.stub_chain(:select, :joins,:where,:all).and_return(@dumb_prod)
    end

    it "should find organization" do
      Organization.should_receive(:first).once.with({:conditions => {:cp_key => @organization.cp_key}}).and_return(@organization)
      get 'index', :organization_id => @organization.cp_key
    end

    it "should find environment" do
      KTEnvironment.should_receive(:find_by_id).once.with(@environment.id).and_return([@environment])
      get 'index', :organization_id => @organization.cp_key, :environment_id => @environment.id
    end

    it "should respond with success" do
      get 'index', :organization_id => @organization.cp_key, :environment_id => @environment.id
      response.should be_success
    end

    it "should respond return product json" do
      get 'index', :organization_id => @organization.cp_key, :environment_id => @environment.id
      response.body.should == @dumb_prod.to_json
    end
  end

  context "show all @products in locker" do
    before do
      @dumb_prod = {:id => @product.id}
      Product.stub!(:all_readable).and_return(@products)
      @products.stub_chain(:select, :joins,:where,:all).and_return(@dumb_prod)
    end

    it "should find organization" do
      Organization.should_receive(:first).once.with({:conditions => {:cp_key => @organization.cp_key}}).and_return(@organization)
      get 'index', :organization_id => @organization.cp_key
    end

    it "should find locker" do
      @organization.should_receive(:locker).once.and_return(@organization.locker)
      get 'index', :organization_id => @organization.cp_key
    end

    it "should respond with success" do
      get 'index', :organization_id => @organization.cp_key, :environment_id => @environment.id
      response.should be_success
    end

    it "should respond return product json" do
      get 'index', :organization_id => @organization.cp_key, :environment_id => @environment.id
      response.body.should == @dumb_prod.to_json
    end
  end

  context "show repositories for a product in an environment" do
    let(:action) { :repositories }
    let(:req) {
      get 'repositories', :organization_id => @organization.cp_key, :environment_id => @organization.locker.id, :id => @product.id
    }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it "should find environment" do
      KTEnvironment.should_receive(:find_by_id).once.with(@environment.id).and_return([@environment])
      get 'repositories', :organization_id => @organization.cp_key, :environment_id => @environment.id, :id => @product.id
    end

    it "should find product" do
      Product.should_receive(:find_by_cp_id).once.with(@product.id.to_s).and_return(@products[0])
      get 'repositories', :organization_id => @organization.cp_key, :environment_id => @environment.id, :id => @product.id
    end

    it "should retrieve all repositories for the product" do
      @product.stub!(:readable?).and_return(true)
      Product.stub!(:all_readable).and_return(@products)
      @product.should_receive(:repos).once.with(@environment, nil).and_return({})
      get 'repositories', :organization_id => @organization.cp_key, :environment_id => @environment.id, :id => @product.id
    end

    it "should return json of product repositories" do
      @product.stub!(:readable?).and_return(true)
      @repositories.stub!(:where).and_return(@repositories)
      get 'repositories', :organization_id => @organization.cp_key, :environment_id => @environment.id, :id => @product.id
      response.body.should == @repositories.to_json
    end
  end

end
