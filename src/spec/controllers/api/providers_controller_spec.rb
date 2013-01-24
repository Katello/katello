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

require 'spec_helper.rb'

describe Api::ProvidersController, :katello => true do
  include LoginHelperMethods
  include AuthorizationHelperMethods
  include LocaleHelperMethods

  let(:user_with_read_permissions) { user_with_permissions { |u| u.can([:read], :providers, nil, @ogranization) } }
  let(:user_without_read_permissions) { user_without_permissions }
  let(:user_with_write_permissions) { user_with_permissions { |u| u.can([:delete, :create, :update], :providers, nil, @ogranization) } }
  let(:user_without_write_permissions) { user_with_permissions { |u| u.can([:read], :providers, nil, @ogranization) } }

  let(:provider_name) { "name" }
  let(:provider_id) { 1 }
  let(:another_provider_name) { "another name" }

  before(:each) do
    disable_org_orchestration
    disable_product_orchestration
    disable_user_orchestration
    set_default_locale
    @organization = new_test_org
    @provider = Provider.create!(:name => provider_name, :provider_type => Provider::CUSTOM,
                                 :organization => @organization)
    Provider.stub!(:find_by_name).and_return(@provider)
    Provider.stub!(:find).and_return(@provider)
    @provider.organization = @organization

    @request.env["HTTP_ACCEPT"] = "application/json"
    @request.env["organization"] = @organization.name

    login_user_api
  end

  let(:to_create) do
    {
      :name => provider_name,
      :description => "a description",
      :repository_url => "https://some.url",
      :provider_type => Provider::CUSTOM,
    }
  end

  let(:product_to_create) do
    {
      :name => "product_name",
      :description => "a description",
      :url => "http://some.url",
    }
  end

  describe "list providers" do

    let(:action) { :index }
    let(:req) { get :index, :organization_id => @organization.name }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it "should scope providers by readable permissions" do
      Provider.should_receive(:readable).with(@organization).and_return({})
      req
    end

  end

  describe "create a provider" do

    let(:action) { :create }
    let(:req) { post 'create', { :provider => to_create, :organization_id => @organization.label } }
    let(:authorized_user) { user_with_write_permissions }
    let(:unauthorized_user) { user_without_write_permissions }
    it_should_behave_like "protected action"

    it "should call Provider.create!" do
      Provider.should_receive(:create!).and_return(Provider.new)
      req
    end
    it_should_behave_like "bad request"  do
      let(:req) do
        bad_req = {:organization_id => @organization.label,
                   :provider =>
                      {:bad_foo => "mwahahaha",
                       :name => "Provider Key",
                       :description => "This is the key string" }
        }.with_indifferent_access
        post :create, bad_req
      end
    end
  end

  describe "update a provider" do

    let(:action) { :update }
    let(:req) { put 'update', { :id => provider_id, :provider => { :name => another_provider_name }} }
    let(:authorized_user) { user_with_write_permissions }
    let(:unauthorized_user) { user_without_write_permissions }
    it_should_behave_like "protected action"

    it "should call Provider#update_attributes" do
      Provider.should_receive(:find).with(provider_id).and_return(@provider)
      @provider.should_receive(:update_attributes!).once
      
      req
    end
    it_should_behave_like "bad request"  do
      let(:req) do
        bad_req = {:id => 123,
                   :provider =>
                      {:bad_foo => "mwahahaha",
                       :name => "prov Key",
                       :description => "This is the key string" }
        }.with_indifferent_access
        put :update, bad_req
      end
    end
  end

  describe "find a provider" do

    let(:action) { :show }
    let(:req) { get :show, :id => provider_id }
    let(:authorized_user) { user_with_read_permissions }
    let(:unauthorized_user) { user_without_read_permissions }
    it_should_behave_like "protected action"

    it "should call Provider.first" do
      Provider.should_receive(:find).with(provider_id).and_return(@provider)
      
      req
    end
  end

  describe "delete a provider" do
 
    let(:action) { :destroy }
    let(:req) { delete :destroy, :id => provider_id }
    let(:authorized_user) { user_with_write_permissions }
    let(:unauthorized_user) { user_without_write_permissions }
    it_should_behave_like "protected action"

   it "should remove the specified provider" do
      Provider.should_receive(:find).with(provider_id).and_return(@provider)
      @provider.should_receive(:destroy).once
      req
    end
  end

  describe "product create" do

    let(:action) { :product_create }
    let(:req) { post 'product_create', { :id => provider_id , :product => product_to_create } }
    let(:authorized_user) { user_with_write_permissions }
    let(:unauthorized_user) { user_without_write_permissions }
    it_should_behave_like "protected action"


    it "should remove the specified provider" do
      Provider.should_receive(:find).with(provider_id).and_return(@provider)
      @provider.should_receive(:add_custom_product).once
      req
    end
  end
  
  describe "import manifest" do

    let(:action) { :import_manifest }
    let(:req) { post :import_manifest, { :id => @organization.redhat_provider.id , :import => @temp_file } }
    let(:authorized_user) { user_with_write_permissions }
    let(:unauthorized_user) { user_without_write_permissions }
    it_should_behave_like "protected action"

    before(:each) do
      @temp_file = mock(File)
      @temp_file.stub(:read).and_return('FILE_DATA')
      @temp_file.stub(:close)
      @temp_file.stub(:write)
      @temp_file.stub(:path).and_return("/a/b/c")

      File.stub(:new).and_return(@temp_file)
    end

    it "should call Provider#import_manifest" do
      Provider.should_receive(:find).with(@organization.redhat_provider.id).and_return(@organization.redhat_provider)
      @organization.redhat_provider.should_receive(:import_manifest).once
      req
    end
  end

  describe "refresh products" do

    let(:action) { :refresh_products }
    let(:req) { post :refresh_products, { :id => @organization.redhat_provider.id  } }
    let(:authorized_user) { user_with_write_permissions }
    let(:unauthorized_user) { user_without_write_permissions }
    it_should_behave_like "protected action"

    it "should refresh all the engineering products of the provider" do
      Provider.should_receive(:find).with(@organization.redhat_provider.id).and_return(@organization.redhat_provider)
      @organization.redhat_provider.should_receive(:refresh_products).once
      req
    end

    it "should fail for no-red-hat provider" do
      Provider.should_receive(:find).with(@organization.redhat_provider.id).and_return(@provider)
      @organization.redhat_provider.should_not_receive(:refresh_products)
      req
      response.should_not be_success
    end
  end

end
