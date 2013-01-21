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

require 'spec_helper'

describe ProvidersController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrchestrationHelper
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  before(:each) do
    login_user
    set_default_locale
    controller.stub(:validate_search).and_return(true)
    @org = new_test_org
    current_organization=@org

  end

  PROVIDER_NAME = "a name"
  ANOTHER_PROVIDER_NAME = "another name"

  describe "update a provider subscriptions" do
    before(:each) do
      @test_export = File.new("#{Rails.root}/spec/controllers/export.zip")
      @contents = {:contents => @test_export}

      @organization = new_test_org
      @provider = @organization.redhat_provider

      @provider.stub(:name).and_return("RH_Provider")
      @provider.stub(:owner_imports).and_return([])

      Resources::Candlepin::Owner.stub!(:pools).and_return({})
    end

    # TODO: move to subscriptions controller tests
    pending "should update a provider subscription" do
      @provider.should_receive(:import_manifest).and_return(true)
      @organization.stub(:redhat_provider).and_return(@provider)
      controller.stub!(:current_organization).and_return(@organization)

      post 'update_redhat_provider', {:provider => @contents}
      response.should be_success
    end

    # TODO: move to subscriptions controller tests
    pending "should try to force a provider update" do
      @provider.should_receive(:import_manifest).
          with(anything(), :force => 'true', :async => true, :notify => true).and_return(true)
      @organization.stub(:redhat_provider).and_return(@provider)
      controller.stub!(:current_organization).and_return(@organization)

      post 'update_redhat_provider', {:provider => @contents, :force_import => "1"}
      response.should be_success
    end

    describe "refresh_products" do
      context "non redhat provider specified" do
        let(:provider) { Provider.create!(:provider_type => Provider::CUSTOM, :name => "foo1", :organization => @organization) }
        it "should not allow refresh for custom providers" do
          put 'refresh_products', :id => provider.id
          response.should_not be_success
        end
      end

      context "redhat provider" do
        let(:redhat) { Provider.redhat.first.tap { |rh| rh.should_receive(:refresh_products).once } }

        before do
          controller.stub(:find_provider) { controller.instance_variable_set "@provider", redhat }
        end

        it "should succeed" do
          put 'refresh_products', :id => redhat.id
          response.should be_success
        end
      end
    end
  end

  describe "should be able to create a custom provider", :katello => true do
    before do
      disable_product_orchestration
      controller.stub(:search_validate).and_return(true)
    end
    it "should work on a good request" do
      name = "prov"
      desc = "desc"
      post :create, :provider => {:name => name, :description => desc }
      response.should be_success
      Provider.where(:name => name, :organization_id => @organization.id).should_not be_empty
    end
    it_should_behave_like "bad request"  do
      let(:req) do
        post :create, :provider => {:name => "name", :bad_description => "desc" }
      end
    end
  end
  describe "rules", :katello => true do
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
      let(:before_success) do
        controller.should_receive(:render_panel_direct) { |obj_class, options, search, start, sort, search_options|
          found = nil
          search_options[:filter].each{|f|  found = f['id'] if f['id'] }
          assert found.include?(@provider.id)
          assert !found.include?(@provider2.id)
          controller.stub(:render)
        }
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

    describe "refresh_provider put" do
      let(:redhat) { Provider.redhat.first.tap { |rh| rh.stub(:editable? => true) } }
      let(:action) { :refresh_provider }
      let(:req) do
        put 'refresh_products', :id => redhat.id
      end
      # for redhat providers, organization privileges are effective
      let(:authorized_user) do
        controller.stub(:find_provider) { controller.instance_variable_set "@provider", redhat }
        user_with_permissions { |u| u.can(:update, :providers, @provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
  end


end
