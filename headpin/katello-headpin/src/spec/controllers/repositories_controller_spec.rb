require 'spec_helper'
require 'ruby-debug'

describe RepositoriesController, :katello => true do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include ProductHelperMethods
  include OrchestrationHelper
  include AuthorizationHelperMethods
  describe "rules" do
    before do
      disable_product_orchestration
      disable_user_orchestration

      @organization = new_test_org
      @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@organization)
      Provider.stub!(:find).and_return(@provider)
      @product = Product.new({:name => "prod"})

      @product.provider = @provider
      @product.environments << @organization.library
      @product.stub(:arch).and_return('noarch')
      @product.save!
      Product.stub!(:find).and_return(@product)
      @repository = MemoStruct.new(:id =>1222)
    end
    describe "GET New" do
      let(:action) {:new}
      let(:req) { get :new, :provider_id => @provider.id, :product_id => @product.id}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :providers,@provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "GET Edit" do
      before do
        Product.stub!(:find).and_return(@product)
        Pulp::Repository.stub!(:find).and_return(@repository)
      end
      let(:action) {:edit}
      let(:req) { get :edit, :provider_id => @provider.id, :product_id => @product.id, :id => @repository.id}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :providers,@provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
  end
  describe "other-tests" do
    before (:each) do
      login_user
      set_default_locale

      @org = new_test_org
      @product = new_test_product(@org, @org.library)
      @gpg = GpgKey.create!(:name => "foo", :organization => @organization, :content => "222")
      @ep = EnvironmentProduct.find_or_create(@organization.library, @product)
      controller.stub!(:current_organization).and_return(@org)
      Candlepin::Content.stub(:create => {:id => "123"})
    end
      let(:invalidrepo) do
        {
          :product_id => @product.id,
          :provider_id => @product.provider.id,
          :repo => {
            :name => 'test',
            :feed => 'www.foo.com'
          }
        }
      end

    describe "Create a Repo" do

      it "should reject invalid urls" do
        controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
        post :create, invalidrepo
        response.should_not be_success
      end
    end

    context "Test gpg create" do
      before do
        @repo_name = "repo-#{rand 10 ** 8}"
        post :create, { :product_id => @product.id,
                        :provider_id => @product.provider.id,
                        :repo => {:name => @repo_name,
                              :feed => "http://foo.com",
                              :gpg_key =>@gpg.id.to_s}}
      end
      specify  do
        response.should be_success
      end
      subject {Repository.find_by_name(@repo_name)}
      it{should_not be_nil}
      its(:gpg_key){should == @gpg}
    end

    context "Test update gpg" do
      before do
        @repo = Repository.create!(:environment_product => @ep, :pulp_id => "pulp-id-#{rand 10**6}",
                                 :name=>"newname#{rand 10**6}", :url => "http://fedorahosted org")
        put :update_gpg_key, { :product_id => @product.id,
                              :provider_id => @product.provider.id,
                                :id => @repo.id,
                                :gpg_key => @gpg.id.to_s}
      end

      specify do
        response.should be_success
      end
      subject {Repository.find(@repo.id)}
      it{should_not be_nil}
      its(:gpg_key){should == @gpg}
    end
  end
end
