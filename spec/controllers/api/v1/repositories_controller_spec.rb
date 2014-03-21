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
describe Api::V1::RepositoriesController do
  describe "(katello)" do
  include OrchestrationHelper
  include AuthorizationHelperMethods
  include OrchestrationHelper
  include ProductHelperMethods
  include RepositoryHelperMethods
  include OrganizationHelperMethods

  let(:task_stubs) do
    @task = mock()
    @task.stubs(:save!).returns(true)
    @task.stubs(:to_json).returns("")
    @task
  end
  let(:url) { "http://localhost" }
  let(:type) { "yum" }

  describe "rules" do
    before(:each) do
      disable_product_orchestration
      disable_user_orchestration

      @organization = new_test_org
      @controller.stubs(:get_organization).returns(@organization)
      @provider = Provider.create!(:provider_type => Provider::CUSTOM, :name => "foo1", :organization => @organization)
      Provider.stubs(:find).returns(@provider)
      @product = Product.new({ :name => "prod", :label => "prod" })

      @product.provider = @provider
      @product.stubs(:arch).returns('noarch')
      @product.save!
      Product.stubs(:find).returns(@product)
      Product.stubs(:find_by_cp_id => @product)
      @repo = new_test_repo(@organization.library, @product, "repo_1", "#{@organization.name}/Library/prod/repo")
      Repository.stubs(:find).returns(@repo)
      PulpSyncStatus.stubs(:using_pulp_task).returns(task_stubs)
      Katello.pulp_server.extensions.package_group.stubs(:all => {})
      Katello.pulp_server.extensions.package_category.stubs(:all => {})
      @test_gpg_content = File.open("#{Engine.root}/spec/assets/gpg_test_key").read
      setup_engine_routes
    end

    describe "for create" do
      let(:action) { :create }
      let(:req) do
        post 'create', :name => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.label
      end
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :providers, @provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "for show" do
      let(:action) { :show }
      let(:req) { get :show, :id => 1 }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :providers, @provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "for destroy" do
      let(:action) { :destroy }
      let(:req) { get :destroy, :id => 1 }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :providers, @provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "for update" do
      let(:action) { :update }
      let(:req) { put :update, :id => 1, :repository => { :gpg_key_name => "test", :url => "" } }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :providers, @provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "for enable" do
      let(:action) { :enable }
      let(:req) { get :enable, :id => 1, :enable => 1 }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :providers, @provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "for package_groups" do
      let(:action) { :package_groups }
      let(:req) { get :package_groups, :id => 1 }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :providers, @provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "for package_group_categories" do
      let(:action) { :package_group_categories }
      let(:req) { get :package_group_categories, :id => 1 }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :providers, @provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
  end

  context "unit tests" do
    before(:each) do
      disable_org_orchestration
      disable_product_orchestration

      @organization     = Organization.create!(:name => ProductTestData::ORG_ID, :label => ProductTestData::ORG_ID, :label => 'admin-org-37070')
      @provider         = @organization.redhat_provider
      @product          = Product.new({ :name => "product for repo test", :label => "product_for_repo_test" })
      @product.provider = @provider
      @product.stubs(:arch).returns('noarch')
      @product.save!
      @request.env["HTTP_ACCEPT"] = "application/json"
      setup_controller_defaults_api

      @test_gpg_content = File.open("#{Engine.root}/spec/assets/gpg_test_key").read

      disable_authorization_rules
    end

    describe "show a repository" do
      it 'should call pulp glue layer' do
        repo_mock = mock()
        Repository.expects(:find).with("1").returns(repo_mock)
        repo_mock.expects(:to_hash)
        get 'show', :id => '1'
      end
    end

    describe "create a repository" do
      before do
        Product.stubs(:find_by_cp_id => @product)
        @product.stubs(:custom?).returns(true)
      end

      it 'should call pulp and candlepin layer' do
        Product.expects(:find_by_cp_id).with('product_1').returns(@product)
        @product.expects(:add_repo).returns({})

        post 'create', :name => 'repo_1', :label => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.label
      end

      describe 'with content_type' do
        let(:attrs) do
          {:name => 'repo_1',
           :label => 'repo_1',
           :url => 'http://www.repo.org',
           :product_id => 'product_1',
           :organization_id => @organization.label,
           :content_type => "puppet"
          }
        end

        it "should use the content_type parameter" do
          @product.expects(:add_repo).with(anything, anything, anything,
                                                  'puppet', anything, anything).returns({})
          post 'create', attrs
          must_respond_with(:success)
        end

        it "should use the default content type if content_type parameter is blank" do
          @product.expects(:add_repo).with(anything, anything, anything,
                                                  'yum', anything, anything).returns({})
          post 'create', attrs.merge(:content_type => "")
          must_respond_with(:success)
        end

        it "should return 400 if content_type is not yum or puppet" do
          post 'create', attrs.merge(:content_type => 'wat')
          response.code.must_equal("422")
        end
      end

      context 'red hat providers' do
        it "does not support creation" do
          @product.stubs(:custom?).returns(false)
          post 'create', :name => 'repo_1', :label => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.label
          response.code.must_equal '400'
        end
      end

      context 'there is already a repo for the product with the same name' do
        it "should notify about conflict" do
          @product.stubs(:add_repo).raises(Errors::ConflictException)
          post 'create', :name => 'repo_1', :label => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.label
          response.code.must_equal '409'
        end
      end

      context 'some gpg key is assigned to the product' do
        let(:product_gpg) { GpgKey.create!(:name => "Product GPG", :content => @test_gpg_content, :organization => @organization) }
        let(:repo_gpg) { GpgKey.create!(:name => "Repo GPG", :content => @test_gpg_content, :organization => @organization) }

        before do
          @product.update_attributes!(:gpg_key => product_gpg)
        end

        context "we dont provide gpg_key_name key" do
          it "should use the product's key" do
            @product.expects(:add_repo).with do |label, name, url, type, unprotected, gpg|
              gpg == product_gpg
            end.returns({})
            post 'create', :name => 'repo_1', :label => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.label
          end
        end

        context "we provide another gpg_key_name key" do
          it "should use provided key" do
            @product.expects(:add_repo).with do |label, name, url, type, unprotected, gpg|
              gpg == repo_gpg
            end.returns({})
            post 'create', :name => 'repo_1', :label => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.label, :gpg_key_name => repo_gpg.name
          end
        end

        context "we provide empty gpg_key_name key" do
          it "should use no gpg key" do
            @product.expects(:add_repo).with do |label, name, url, type, unprotected, gpg|
              gpg == nil
            end.returns({})
            post 'create', :name => 'repo_1', :label => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.label, :gpg_key_name => ""
          end
        end

        context "should be protected by default" do
          it "should use no gpg key" do
            @product.expects(:add_repo).with do |label, name, url, type, unprotected, gpg|
              unprotected == false
            end.returns({})
            post 'create', :name => 'repo_1', :label => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.label, :gpg_key_name => ""
          end
        end

        context "should be able to be unprotected" do
          it "should use no gpg key" do
            @product.expects(:add_repo).with do |label, name, url, type, unprotected, gpg|
              unprotected == true
            end.returns({})
            post 'create', :name => 'repo_1', :label => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.label, :gpg_key_name => "", :unprotected => true
          end
        end

        context "the url is empty" do
          it "should succesfully call Repository.create!" do
            disable_repo_orchestration
            repo = {}
            repo.expects(:generate_metadata).returns(true)
            Repository.expects(:create!).returns(repo)
            post 'create', :name => 'repo_1', :label => 'repo_1', :url => '',
              :product_id => 'product_1', :gpg_key_name => "",
              :organization_id => @organization.label
            must_respond_with(:success)
          end
        end
      end
    end

    describe "update a repository" do
      before do
        @repo = mock
      end

      context "Bad request" do
        before { @repo.stubs(:redhat? => false) }
        let(:req) do
          bad_req = { :id         => 123,
                      :repository =>
                          { :bad_foo      => "mwahahaha",
                            :gpg_key_name => "Gpg Key" }
          }.with_indifferent_access
          put :update, bad_req
        end

        it_should_behave_like "bad request"
      end

      context "Custom repo" do
        before do
          Repository.expects(:find).with("1").returns(@repo)
          @repo.stubs :redhat? => false, :to_hash => {}
        end

        it 'should update values thet migth change' do
          @repo.expects(:update_attributes!).with("gpg_key_name" => "gpg_key")
          put :update, { :id => '1', :repository => { :gpg_key_name => "gpg_key" } }
        end
      end

      context "RH repo" do

        before { @repo.stubs(:redhat? => true) }

        it "should fail with bad request" do
          put :update, { :id => '1', :repository => { :gpg_key_name => "gpg_key", :name => "another name" } }
          response.status.must_equal HttpErrors::UNPROCESSABLE_ENTITY
        end

      end
    end

    describe "repository discovery" do
      it "should call Resources::Pulp::Proxy.post" do
        url  = "http://url.org"
        type = "yum"

        post 'create', :name => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.label
      end

      context 'there is already a repo for the product with the same name' do
        before do
          Product.stubs(:find_by_cp_id => @product)
          @product.stubs(:add_repo).raises(Errors::ConflictException)
          @product.stubs(:custom?).returns(true)
        end

        it "should notify about conflict" do
          post 'create', :name => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.label
          response.code.must_equal '409'
        end
      end

    end

    describe "show a repository" do
      it 'should call pulp glue layer' do
        repo_mock = mock()
        Repository.expects(:find).with("1").returns(repo_mock)
        repo_mock.expects(:to_hash)
        get 'show', :id => '1'
      end
    end

    describe "get list of repository package groups" do
      subject { get :package_groups, :id => "123" }
      before do
        @repo = Repository.new(:pulp_id => "123", :id => "123")
        Repository.stubs(:find).returns(@repo)
        Katello.pulp_server.extensions.repository.stubs(:package_groups).returns([])
      end
      it "should call Pulp layer" do
        Katello.pulp_server.extensions.repository.expects(:package_groups).with("123")
        subject
      end
      it { must_respond_with(:success) }
    end

    describe "get list of repository package categories" do
      subject { get :package_group_categories, :id => "123" }

      before do
        @repo = Repository.new(:pulp_id => "123", :id => "123")
        Repository.stubs(:find).returns(@repo)
        Katello.pulp_server.extensions.repository.stubs(:package_categories).returns([])
      end
      it "should call Pulp layer" do
        Katello.pulp_server.extensions.repository.expects(:package_categories).with("123")
        subject
      end
      it { must_respond_with(:success) }
    end
  end

end
end
end