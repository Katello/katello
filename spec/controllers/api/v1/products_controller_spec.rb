#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module Katello
describe Api::V1::ProductsController do
  describe "katello" do
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  include ProductHelperMethods
  include RepositoryHelperMethods

  let(:user_with_read_permissions) { user_with_permissions { |u| u.can([:read], :providers, @provider.id, @organization) } }
  let(:user_without_read_permissions) { user_without_permissions }

  let(:user_with_update_permissions) { user_with_permissions { |u| u.can([:update], :providers, @provider.id, @organization) } }
  let(:user_without_update_permissions) { user_with_permissions { |u| u.can([:read], :providers, @provider.id, @organization) } }

  before (:each) do
    disable_org_orchestration
    disable_product_orchestration
    disable_user_orchestration

    @organization = new_test_org

    @test_gpg_content = File.open("#{Engine.root}/spec/assets/gpg_test_key").read

    @environment = create_environment(:name => "foo123", :label => "foo123", :organization => @organization, :prior => @organization.library)
    @provider    = Provider.create!(:name         => "provider", :provider_type => Provider::CUSTOM,
                                    :organization => @organization, :repository_url => "https://something.url/stuff")
    @product     = Product.new({ :name => "prod", :label => "prod" })

    @product.provider = @provider
    @product.stubs(:arch).returns('noarch')
    @product.save!
    @repo_library = new_test_repo(@organization.library, @product, "repo", "#{@organization.name}/Library/prod/repo")

    @repo = promote(@repo_library, @environment)

    @products     = [@product]
    @repositories = [@repo]

    @product = @products[0]

    Product.stubs(:find_by_cp_id).returns(@product)
    Product.stubs(:find).returns(@product)

    Product.stubs(:select).returns(@products)
    @product.stubs(:repos).returns(@repositories)
    @product.stubs(:sync_state => Katello::PulpSyncStatus::Status::NOT_SYNCED)

    @request.env["HTTP_ACCEPT"] = "application/json"
    setup_controller_defaults_api
  end

  describe "show product" do
    before do
      Katello.pulp_server.extensions.repository.stubs(:retrieve).returns(RepoTestData::REPO_PROPERTIES)
    end

    let(:action) { :show }
    let(:req) { get 'show', :organization_id => @organization.name, :id => @product.id }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    subject { req }

    it {req.must_respond_with(:success) }
  end

  describe "update product" do
    let(:gpg_key) { GpgKey.create!(:name => "Gpg key", :content => @test_gpg_content, :organization => @organization) }

    before do
      Katello.pulp_server.extensions.repository.stubs(:retrieve).returns(RepoTestData::REPO_PROPERTIES)
      Product.stubs(:find_by_cp_id).with(@product.cp_id).returns(@product)
      @product.stubs(:update_attributes! => true)
    end

    let(:action) { :update }
    let(:req) { put 'update', :id => @product.cp_id, :organization_id => @organization.label, :product => { :gpg_key_name => gpg_key.name, :description => "another description" } }
    let(:authorized_user) { user_with_update_permissions }
    let(:unauthorized_user) { user_without_update_permissions }

    it_should_behave_like "protected action"

    describe "invalid params" do
      let(:req) do
        bad_req = { :id              => @product.cp_id,
                    :organization_id => @organization.label,
                    :product         => { :bad_param    => "100",
                                          :gpg_key_name => gpg_key.name,
                                          :description  => "another description" }
        }.with_indifferent_access
        put :update, bad_req
      end
      it_should_behave_like "bad request"
    end

    context "custom product" do
      subject { req }

      it { req.must_respond_with(:success) }

      it "should change allowed attributes" do
        @product.expects(:gpg_key_name=)
        @product.expects(:update_attributes!).with("description" => "another description")
        req
      end

      it "should reset repos' GPGs, if updating recursive" do
        @product.expects(:reset_repo_gpgs!)
        put 'update', :id => @product.cp_id, :organization_id => @organization.label, :product => { :gpg_key_name => gpg_key.name, :description => "another description", :recursive => true }
      end
    end

    context "RH product" do
      subject { req }

      before do
        @product.provider.provider_type = Provider::REDHAT
      end

      it do
        req
        response.code.must_equal("400")
      end
    end
  end

  context "show all @products" do
    before do
      @dumb_prod = { :id => @product.id }
      Product.stubs(:all_readable).returns(@products)
      @products.stubs(:select).returns(stub(:joins => stub(:where =>
                                                  stub(:all => @dumb_prod))))

#      @products.stub_chain(:select, :joins, :where, :all).returns(@dumb_prod)
    end

    it "should find organization" do
      @controller.expects(:find_optional_organization)
      get 'index', :organization_id => @organization.label
    end

    it "should find library" do
      get 'index', :organization_id => @organization.label
      must_respond_with(:success)
    end

    it "should respond with success" do
      get 'index', :organization_id => @organization.label
      must_respond_with(:success)
    end

    it "should respond return product json" do
      get 'index', :organization_id => @organization.label
      response.body.must_equal @dumb_prod.to_json
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
      KTEnvironment.expects(:find_by_id).once.with(@environment.id.to_s).returns([@environment])
      get 'repositories', :organization_id => @organization.label, :environment_id => @environment.id.to_s, :id => @product.id
    end

    it "should find product" do
      Product.expects(:find_by_cp_id).once.with(@product.id.to_s, @organization).returns(@products[0])
      get 'repositories', :organization_id => @organization.label, :environment_id => @environment.id, :id => @product.id
    end

    it "should retrieve all repositories for the product" do
      @product.stubs(:readable?).returns(true)
      Product.stubs(:all_readable).returns(@products)
      @product.expects(:repos).once.with(@organization.library, nil, nil).returns({})
      get 'repositories', :organization_id => @organization.label, :id => @product.id
    end

    it "should return json of product repositories" do
      Package.stubs(:search).returns({})
      PuppetModule.stubs(:search).returns({})
      Repository.any_instance.stubs(:last_sync).returns(nil)

      @product.stubs(:readable?).returns(true)
      @repositories.stubs(:where).returns(@repositories)
      get 'repositories', :organization_id => @organization.label, :environment_id => @organization.library.id, :id => @product.id
      response.body.must_equal @repositories.to_json
    end

    it "should return 400 for a non-library environment with no content_view_id" do
      @product.stubs(:readable?).returns(true)
      @repositories.stubs(:where).returns(@repositories)
      get 'repositories', :organization_id => @organization.label, :environment_id => @environment.id, :id => @product.id
      response.status.must_equal(400)
    end

    it "should call product repos with a content view" do
      @content_view = build_stubbed(:content_view)
      @product.stubs(:readable?).returns(true)
      @repositories.stubs(:where).returns(@repositories)
      ContentView.stubs(:readable).returns(stub(:find => @content_view))
      @product.expects(:repos).with(@environment, nil, @content_view)
      get 'repositories', :organization_id => @organization.label,
        :environment_id => @environment.id, :id => @product.id,
        :content_view_id => @content_view.id
    end
  end
end
end
end