require 'spec_helper'
require 'lib/authorization_rules'

describe Api::RepositoriesController do
  include OrchestrationHelper
  include LoginHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper
  include ProductHelperMethods
  include OrganizationHelperMethods

  let(:task_stub) do
    @task = mock(PulpTaskStatus)
    @task.stub(:save!).and_return(true)
    @task.stub(:to_json).and_return("")
    @task
  end
  let(:url) { "http://localhost" }
  let(:type) { "yum" }

  describe "rules" do
    before(:each) do
      disable_product_orchestration
      disable_user_orchestration

      @organization = new_test_org
      Organization.stub!(:first).and_return(@organization)
      @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@organization)
      Provider.stub!(:find).and_return(@provider)
      @product = Product.new({:name => "prod"})

      @product.provider = @provider
      @product.environments << @organization.library
      @product.stub(:arch).and_return('noarch')
      @product.save!
      Product.stub!(:find).and_return(@product)
      Product.stub!(:find_by_cp_id).and_return(@product)
      ep = EnvironmentProduct.find_or_create(@organization.library, @product)
      @repository = Repository.create!(:environment_product => ep, :name=> "repo_1", :pulp_id=>"1")
      Repository.stub(:find).and_return(@repository)
      Pulp::Repository.stub(:start_discovery).and_return({})
      PulpSyncStatus.stub(:using_pulp_task).and_return(task_stub)
      Pulp::PackageGroup.stub(:all => {})
      Pulp::PackageGroupCategory.stub(:all => {})
    end
    describe "for create" do
      let(:action) {:create}
      let(:req) do
        post 'create', :name => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.cp_key
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
      let(:action) {:show}
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
      let(:action) {:destroy}
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
      let(:action) {:update}
      let(:req) { put :update, :id => 1, :repository =>{:gpg_key_name => "test" }}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :providers, @provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
    describe "for enable" do
      let(:action) {:enable}
      let(:req) { get :enable, :id => 1, :enable => 1 }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :providers, @provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
    describe "for discovery" do
      let(:action) {:discovery}
      let(:req) do
        post 'discovery', :organization_id => "ACME", :url => url, :type => type
      end
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :organizations, @organization.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
    describe "for package_groups" do
      let(:action) {:package_groups}
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
      let(:action) {:package_group_categories}
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

      @organization = Organization.create!(:name => ProductTestData::ORG_ID, :cp_key => 'admin-org-37070')
      @provider     = @organization.redhat_provider
      @product = Product.new({:name => "product for repo test"})
      @product.provider = @provider
      @product.environments << @organization.library
      @product.stub(:arch).and_return('noarch')
      @product.save!
      @request.env["HTTP_ACCEPT"] = "application/json"
      login_user_api

      disable_authorization_rules
    end

  describe "show a repository" do
    it 'should call pulp glue layer' do
      repo_mock = mock(Glue::Pulp::Repo)
      Repository.should_receive(:find).with("1").and_return(repo_mock)
      repo_mock.should_receive(:to_hash)
      get 'show', :id => '1'
    end
  end

    describe "create a repository" do
    before do
      Product.stub(:find_by_cp_id => @product)
    end

    it 'should call pulp and candlepin layer' do
      Product.should_receive(:find_by_cp_id).with('product_1').and_return(@product)
      @product.should_receive(:add_repo).and_return({})

      post 'create', :name => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.cp_key
    end

    context 'there is already a repo for the product with the same name' do
      it "should notify about conflict" do
        @product.stub(:add_repo).and_return { raise Errors::ConflictException }
        post 'create', :name => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.cp_key
        response.code.should == '409'
      end
    end

    context 'some gpg key is assigned to the product' do
      let(:product_gpg) { GpgKey.create!(:name => "Product GPG", :content => "100", :organization => @organization) }
      let(:repo_gpg) { GpgKey.create!(:name => "Repo GPG", :content => "200", :organization => @organization) }

      before do
        @product.update_attributes!(:gpg_key => product_gpg)
      end

      context "we dont provide gpg_key_name key" do
        it "should use the product's key" do
          @product.should_receive(:add_repo).with do |name, url, type, gpg|
            gpg == product_gpg
          end.and_return({})
          post 'create', :name => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.cp_key
        end
      end

      context "we provide another gpg_key_name key" do
        it "should use provided key" do
          @product.should_receive(:add_repo).with do |name, url, type, gpg|
            gpg == repo_gpg
          end.and_return({})
          post 'create', :name => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.cp_key, :gpg_key_name => repo_gpg.name
        end
      end

      context "we provide empty gpg_key_name key" do
        it "should use no gpg key" do
          @product.should_receive(:add_repo).with do |name, url, type, gpg|
            gpg == nil
          end.and_return({})
          post 'create', :name => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.cp_key, :gpg_key_name => ""
        end
      end
    end

  end
  describe "update a repository" do
    before do
      @repo = mock(Glue::Pulp::Repo)
    end

    context "Bad request" do
      before { @repo.stub(:redhat? => false) }
      it_should_behave_like "bad request"  do
        let(:req) do
          bad_req = {:id => 123,
                     :repository =>
                        {:bad_foo => "mwahahaha",
                         :gpg_key_name => "Gpg Key"}
          }.with_indifferent_access
          put :update, bad_req
        end
      end

    end

    context "Custom repo" do
      before do
            Repository.should_receive(:find).with("1").and_return(@repo)
            @repo.stub(:redhat? => false)
      end

      it 'should update values thet migth change' do
        @repo.should_receive(:update_attributes!).with("gpg_key_name" => "gpg_key")
        put :update, {:id => '1', :repository => {:gpg_key_name => "gpg_key"}}
      end
    end

    context "RH repo" do

      before { @repo.stub(:redhat? => true) }

      it "should fail with bad request" do
        put :update, {:id => '1', :repository => {:gpg_key_name => "gpg_key", :name => "another name"}}
        response.code.should eq("400")
      end

    end
  end

  describe "repository discovery" do
    it "should call Pulp::Proxy.post" do
      url  = "http://url.org"
      type = "yum"

        post 'create', :name => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.cp_key
      end

      context 'there is already a repo for the product with the same name' do
        before do
          Product.stub(:find_by_cp_id => @product)
          @product.stub(:add_repo).and_return { raise Errors::ConflictException }
        end

        it "should notify about conflict" do
          post 'create', :name => 'repo_1', :url => 'http://www.repo.org', :product_id => 'product_1', :organization_id => @organization.cp_key
          response.code.should == '409'
        end
      end

    end

    describe "show a repository" do
      it 'should call pulp glue layer' do
        repo_mock = mock(Glue::Pulp::Repo)
        Repository.should_receive(:find).with("1").and_return(repo_mock)
        repo_mock.should_receive(:to_hash)
        get 'show', :id => '1'
      end
    end

    describe "repository discovery" do
      it "should call Pulp::Proxy.post" do
        Pulp::Repository.should_receive(:start_discovery).with(url, type).once.and_return({})
        PulpSyncStatus.should_receive(:using_pulp_task).with({}).and_return(task_stub)
        Organization.stub!(:first).and_return(@organization)

        post 'discovery', :organization_id => "ACME", :url => url, :type => type
      end
    end


    describe "trigger sync complete" do
      before do
        @repo = Repository.new(:pulp_id=>"123", :id=>"123")
        @repo.stub(:environment).and_return(KTEnvironment.new(:name=>"FOO"))
        Repository.stub(:where).and_return([@repo])
        @fake_async = OpenStruct.new
      end
      it "should call async task correctly with no forwarded header" do
        @repo.should_receive(:async).and_return(@fake_async)
        @fake_async.should_receive(:after_sync)
        request.env['RAW_POST_DATA'] = {:task_id=>"123", :repo_id=>"123"}.to_json
        post :sync_complete, {}
        response.should be_success
      end

      it "should accept a forwarded request from ipv4 localhost" do
        request.env["HTTP_X_FORWARDED_FOR"] = '127.0.0.1'
        @repo.should_receive(:async).and_return(@fake_async)
        @fake_async.should_receive(:after_sync)
        request.env['RAW_POST_DATA'] = {:task_id=>"123", :repo_id=>"123"}.to_json
        post :sync_complete, {}
        response.should be_success
      end

      it "should accept a forwarded request from ipv6 localhost" do
        request.env["HTTP_X_FORWARDED_FOR"] = '::1'
        @repo.should_receive(:async).and_return(@fake_async)
        @fake_async.should_receive(:after_sync)
        request.env['RAW_POST_DATA'] = {:task_id=>"123", :repo_id=>"123"}.to_json
        post :sync_complete, {}
        response.should be_success
      end

      it "should get a permission denied if forwarded from a different ip" do
        request.env["HTTP_X_FORWARDED_FOR"] = '192.168.0.1'
        post :sync_complete, {}
        response.status.should == 403
      end


    end

    describe "get list of repository package groups" do
      subject { get :package_groups, :id => "123" }
      before do
          @repo = Repository.new(:pulp_id=>"123", :id=>"123")
          Repository.stub(:find).and_return(@repo)
          Pulp::PackageGroup.stub(:all => {})
      end
      it "should call Pulp layer" do
        Pulp::PackageGroup.should_receive(:all).with("123")
        subject
      end
      it { should be_success }
    end

    describe "get list of repository package categories" do
      subject { get :package_group_categories, :id => "123" }

      before do
          @repo = Repository.new(:pulp_id=>"123", :id=>"123")
          Repository.stub(:find).and_return(@repo)
          Pulp::PackageGroupCategory.stub(:all => {})
      end
      it "should call Pulp layer" do
        Pulp::PackageGroupCategory.should_receive(:all).with("123")
        subject
      end
      it { should be_success }
    end
  end

end
