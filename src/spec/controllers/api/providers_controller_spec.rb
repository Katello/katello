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

describe Api::ProvidersController do
  include LoginHelperMethods

  PROVIDER_NAME = "name"
  PROVIDER_ID = 1
  ANOTHER_PROVIDER_NAME = "another name"

  before(:each) do
    @organization = Organization.new(:name => "organization100", :cp_key => "organization100")
    Organization.stub!(:first).and_return(@organization)

    @provider = Provider.new(:name => PROVIDER_NAME)
    Provider.stub!(:find_by_name).and_return(@provider)
    Provider.stub!(:find).and_return(@provider)

    @request.env["HTTP_ACCEPT"] = "application/json"
    @request.env["organization"] = @organization.name

    login_user_api
  end

  let(:to_create) do
    {
      :name => PROVIDER_NAME,
      :description => "a description",
      :repository_url => "https://some.url",
      :provider_type => Provider::REDHAT,
      :login_credential_attributes => {
          :username => 'username',
          :password => 'password'
      }
    }
  end

  let(:product_to_create) do
    {
      :name => "product_name",
      :description => "a description",
      :url => "http://some.url",
    }
  end

  describe "create a provider" do
    it "should call Provider.create!" do
      Provider.should_receive(:create!).and_return(Provider.new)
      post 'create', { :provider => to_create, :organization_id => @organization.cp_key }
    end
  end

  describe "update a provider" do
    it "should call Provider#update_attributes" do
      Provider.should_receive(:find).with(PROVIDER_ID).and_return(@provider)
      @provider.should_receive(:update_attributes!).once
      
      put 'update', { :id => PROVIDER_ID, :provider => { :name => ANOTHER_PROVIDER_NAME }}
    end
  end

  describe "find a provider" do
    it "should call Provider.first" do
      Provider.should_receive(:find).with(PROVIDER_ID).and_return(@provider)
      
      get :show, :id => PROVIDER_ID
    end
  end

  describe "delete a provider" do
    it "should remove the specified provider" do
      Provider.should_receive(:find).with(PROVIDER_ID).and_return(@provider)
      @provider.should_receive(:destroy).once
      delete :destroy, :id => PROVIDER_ID
    end
  end

  describe "product create" do
    it "should remove the specified provider" do
      Provider.should_receive(:find).with(PROVIDER_ID).and_return(@provider)
      @provider.should_receive(:add_custom_product).once
      post 'product_create', { :id => PROVIDER_ID , :product => product_to_create }
    end
  end
  
  describe "import manifest" do
    
    before(:each) do
      @temp_file = mock(File)
      @temp_file.stub(:read).and_return('FILE_DATA')
      @temp_file.stub(:close)
      @temp_file.stub(:write)
      @temp_file.stub(:path).and_return("/a/b/c")
      
      File.stub(:new).and_return(@temp_file)
    end
      
    it "should call Provider#import_manifest" do
      Provider.should_receive(:find).with(PROVIDER_ID).and_return(@provider)
      @provider.should_receive(:import_manifest).once
      post :import_manifest, { :id => PROVIDER_ID , :import => @temp_file }
    end
  end

end
