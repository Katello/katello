require 'spec_helper'
require 'ruby-debug'

describe RepositoriesController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include ProductHelperMethods
  include OrchestrationHelper
  include AuthorizationHelperMethods
  describe "rules" do
    before do
      @organization = new_test_org
      @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@organization)
      Provider.stub!(:find).and_return(@provider)
      @product = OpenStruct.new(:provider => @provider, :id => 1000)
      @repository = OpenStruct.new(:id =>1222)
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
      @product = new_test_product(@org, @org.locker)
      @product.stub!(:add_new_content)
      controller.stub!(:current_organization).and_return(@org)
    end
      let(:invalidrepo) do
        {
          :product_id => '1',
          :provider_id => '1',
          :repo => {
            :name => 'test',
            :feed => 'www.foo.com'
          }
        }
      end

    describe "Create a Repo" do

      it "should reject invalid urls" do
        controller.should_receive(:errors)
        post :create, invalidrepo
        response.should_not be_success
      end
    end
  end
end
