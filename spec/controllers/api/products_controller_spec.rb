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

require 'spec_helper'

describe Api::ProductsController, :katello => true do
  include LoginHelperMethods
  include AuthorizationHelperMethods
  include ProductHelperMethods
  include RepositoryHelperMethods
  include LocaleHelperMethods

  let(:user_with_read_permissions) { user_with_permissions { |u| u.can([:read], :providers, @provider.id, @organization) } }
  let(:user_without_read_permissions) { user_without_permissions }

  let(:user_with_update_permissions) { user_with_permissions { |u| u.can([:update], :providers, @provider.id, @organization) } }
  let(:user_without_update_permissions) { user_with_permissions { |u| u.can([:read], :providers, @provider.id, @organization) } }

  before (:each) do
    disable_org_orchestration
    disable_product_orchestration
    disable_user_orchestration

    @organization = new_test_org

    @environment = KTEnvironment.create!(:name=>"foo123", :label=> "foo123", :organization => @organization, :prior =>@organization.library)
    @provider = Provider.create!(:name => "provider", :provider_type => Provider::CUSTOM,
                                 :organization => @organization, :repository_url => "https://something.url/stuff")
    @product = Product.new({:name=>"prod", :label=> "prod"})

    @product.provider = @provider
    @product.environments << @organization.library
    @product.stub(:arch).and_return('noarch')
    @product.save!
    ep_library = EnvironmentProduct.find_or_create(@organization.library, @product)
    @repo_library = new_test_repo(ep_library, "repo", "#{@organization.name}/Library/prod/repo")

    @repo = promote(@repo_library, @environment)

    @products = [@product]
    @repositories = [@repo]

    @product = @products[0]

    Product.stub!(:find_by_cp_id).and_return(@product)
    Product.stub!(:find).and_return(@product)

    Product.stub!(:select).and_return(@products)
    @product.stub(:repos).and_return(@repositories)
    @product.stub(:sync_state => ::PulpSyncStatus::Status::NOT_SYNCED)

    @request.env["HTTP_ACCEPT"] = "application/json"
    login_user_api
  end

  describe "show product" do
    before do
      Runcible::Extensions::Repository.stub(:retrieve).and_return(RepoTestData::REPO_PROPERTIES)
    end

    let(:action) { :show }
    let(:req) { get 'show', :organization_id => @organization.name, :id => @product.id }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    subject { req }

    it { should be_success }
  end

  describe "update product" do
    let(:gpg_key) { GpgKey.create!(:name => "Gpg key", :content => "100", :organization => @organization) }

    before do
      Runcible::Extensions::Repository.stub(:retrieve).and_return(RepoTestData::REPO_PROPERTIES)
      Product.stub(:find_by_cp_id).with(@product.cp_id).and_return(@product)
      @product.stub(:update_attributes! => true)
    end

    let(:action) { :update }
    let(:req) { put 'update', :id => @product.cp_id, :organization_id => @organization.label, :product => {:gpg_key_name => gpg_key.name, :description => "another description" } }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }

    it_should_behave_like "protected action"

    it_should_behave_like "bad request" do
      let(:req) do
        bad_req = {:id => @product.cp_id,
                   :organization_id => @organization.label,
                   :product => {:bad_param => "100",
                                :gpg_key_name => gpg_key.name,
                                :description => "another description" }
        }.with_indifferent_access
        put :update, bad_req
      end
    end

    context "custom product" do
      subject { req }

      it { should be_success }

      it "should change allowed attributes" do
        @product.should_receive(:update_attributes!).with("gpg_key_name" => gpg_key.name, "description" => "another description")
        req
      end

      it "should reset repos' GPGs, if updating recursive" do
        @product.should_receive(:reset_repo_gpgs!)
        put 'update', :id => @product.cp_id, :organization_id => @organization.label, :product => {:gpg_key_name => gpg_key.name, :description => "another description", :recursive => true }
      end
    end

    context "RH product" do
      subject { req }

      before do
        @product.provider.provider_type = Provider::REDHAT
      end

      it do
        req
        response.code.should eq("400")
      end
    end
  end

  context "show all @products in an environment" do

    let(:action) { :index }
    let(:req) { get 'index', :organization_id => @organization.label }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    before do
      @dumb_prod = {:id => @product.id}
      Product.stub!(:all_readable).and_return(@products)
      @products.stub_chain(:select, :joins,:where,:all).and_return(@dumb_prod)
    end

    it "should find organization" do
      @controller.should_receive(:find_optional_organization)
      get 'index', :organization_id => @organization.label
    end

    it "should find environment" do
      KTEnvironment.should_receive(:find_by_id).once.with(@environment.id.to_s).and_return([@environment])
      get 'index', :organization_id => @organization.label, :environment_id => @environment.id.to_s
    end

    it "should respond with success" do
      get 'index', :organization_id => @organization.label, :environment_id => @environment.id
      response.should be_success
    end

    it "should respond return product json" do
      get 'index', :organization_id => @organization.label, :environment_id => @environment.id
      response.body.should == @dumb_prod.to_json
    end
  end

  context "show all @products in library" do
    before do
      @dumb_prod = {:id => @product.id}
      Product.stub!(:all_readable).and_return(@products)
      @products.stub_chain(:select, :joins,:where,:all).and_return(@dumb_prod)
    end

    it "should find organization" do
      @controller.should_receive(:find_optional_organization)
      get 'index', :organization_id => @organization.label
    end

    it "should find library" do
      get 'index', :organization_id => @organization.label
      response.should be_success
    end

    it "should respond with success" do
      get 'index', :organization_id => @organization.label, :environment_id => @environment.id
      response.should be_success
    end

    it "should respond return product json" do
      get 'index', :organization_id => @organization.label, :environment_id => @environment.id
      response.body.should == @dumb_prod.to_json
    end
  end

  context "show repositories for a product in an environment" do
    let(:action) { :repositories }
    let(:req) {
      get 'repositories', :organization_id => @organization.label, :environment_id => @organization.library.id, :id => @product.id
    }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it "should find environment" do
      KTEnvironment.should_receive(:find_by_id).once.with(@environment.id.to_s).and_return([@environment])
      get 'repositories', :organization_id => @organization.label, :environment_id => @environment.id.to_s, :id => @product.id
    end

    it "should find product" do
      Product.should_receive(:find_by_cp_id).once.with(@product.id.to_s).and_return(@products[0])
      get 'repositories', :organization_id => @organization.label, :environment_id => @environment.id, :id => @product.id
    end

    it "should retrieve all repositories for the product" do
      @product.stub!(:readable?).and_return(true)
      Product.stub!(:all_readable).and_return(@products)
      @product.should_receive(:repos).once.with(@environment, nil).and_return({})
      get 'repositories', :organization_id => @organization.label, :environment_id => @environment.id, :id => @product.id
    end

    it "should return json of product repositories" do
      @product.stub!(:readable?).and_return(true)
      @repositories.stub!(:where).and_return(@repositories)
      get 'repositories', :organization_id => @organization.label, :environment_id => @environment.id, :id => @product.id
      response.body.should == @repositories.to_json
    end
  end

end
