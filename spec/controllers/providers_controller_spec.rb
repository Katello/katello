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

require 'katello_test_helper'

module Katello
  describe ProvidersController do

    include LocaleHelperMethods
    include OrchestrationHelper
    include OrganizationHelperMethods
    include AuthorizationHelperMethods

    before(:each) do
      setup_controller_defaults
      @controller.stubs(:validate_search).returns(true)
      @org = new_test_org
      current_organization=@org
    end

    PROVIDER_NAME = "a name"
    ANOTHER_PROVIDER_NAME = "another name"

    describe "update a provider subscriptions" do
      before(:each) do
        @test_export = File.new("#{Katello::Engine.root}/spec/controllers/export.zip")
        @contents = {:contents => @test_export}

        @organization = new_test_org
        @provider = @organization.redhat_provider

        @provider.stubs(:name).returns("RH_Provider")
        @provider.stubs(:owner_imports).returns([])

        Resources::Candlepin::Owner.stubs(:pools).returns({})
      end

      it "Should be able to get repo discovery screen" do
        get 'repo_discovery', {:id=>@provider.id}
        must_respond_with(:success)
      end

      it "Should be able to get discovered repos" do
        get 'discovered_repos', {:id=>@provider.id}
        must_respond_with(:success)
      end

      it "should be able to get new discovered urls" do
        @controller.expects(:render).twice
        get 'new_discovered_repos', {:id=>@provider.id, :urls=>['http://redhat.com/foo']}
        must_respond_with(:success)
      end

      it "Should be able to start discovery" do
        url = 'http://redhat.com/foo'
        @provider.expects(:discover_repos)
        @provider.expects(:discovery_url=).with(url)
        Provider.stubs(:find).returns @provider
        post 'discover', {:id=>@provider.id, :url=>url}
        must_respond_with(:success)
      end

      it "Should be able to cancel discovery" do
        @provider.expects(:discovery_task=).with(nil)
        Provider.stubs(:find).returns @provider
        post 'cancel_discovery', {:id=>@provider.id}
        must_respond_with(:success)
      end
    end

    describe "should be able to create a custom provider (katello)" do
      before do
        disable_product_orchestration
        @controller.stubs(:search_validate).returns(true)
      end
      it "should work on a good request" do
        name = "prov"
        desc = "desc"
        post :create, :provider => {:name => name, :description => desc }
        must_respond_with(:success)
        Provider.where(:name => name, :organization_id => @organization.id).wont_be_empty
      end
      let(:req) do
        post :create, :provider => {:name => "name", :bad_description => "desc" }
      end
      it_should_behave_like "bad request"
    end
    describe "rules (katello)" do
      before (:each) do
        @organization = new_test_org
        @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@organization)
        @provider2 = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo2", :organization=>@organization)
      end
      describe "GET index" do
        let(:action) {:items}
        let(:req) { get :items }
        let(:authorized_user) do
          user_with_permissions { |u| u.can(:read, :providers, @provider.id, @organization) }
        end
        let(:unauthorized_user) do
          user_without_permissions
        end

        it_should_behave_like "protected action"
      end

      describe "update org put" do

        let(:action) {:update}
        let(:req) do
          put 'update', :id => @provider.id, :name=>"bar"
        end
        let(:authorized_user) do
          user_with_permissions { |u| u.can(:update, :providers, @provider.id, @organization) }
        end
        let(:unauthorized_user) do
          user_without_permissions
        end
        it_should_behave_like "protected action"
      end

    end

  end
end
