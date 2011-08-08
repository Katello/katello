require 'spec_helper'
require 'ruby-debug'

describe RepositoriesController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include ProductHelperMethods
  include OrchestrationHelper

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
