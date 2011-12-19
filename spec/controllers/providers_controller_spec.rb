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
    controller.stub!(:notice)
    controller.stub!(:errors)

    @org = new_test_org
    current_organization=@org

  end

  PROVIDER_NAME = "a name"
  ANOTHER_PROVIDER_NAME = "another name"


  describe "update a provider subscriptions" do
    before(:each) do
      @organization = new_test_org

      provider = @organization.redhat_provider
      provider.should_receive(:import_manifest).and_return(true)
      provider.stub(:name).and_return("RH_Provider")
      provider.stub(:owner_imports).and_return([])

      @organization.stub(:redhat_provider).and_return(provider)
      controller.stub!(:current_organization).and_return(@organization)

      Candlepin::Owner.stub!(:pools).and_return({})
    end

    it "should update a provider subscription" do
      test_export = File.new("#{Rails.root}/spec/controllers/export.zip")
      contents = {:contents => test_export}

      post 'update_redhat_provider', {:provider => contents}
      response.should be_success
    end

  end




  describe "rules" do
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
        controller.should_receive(:render_panel_direct) { |obj_class, options, search, start, sort, filters|
          found = nil
          filters.each{|f|  found = f['id'] if f['id'] }
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
  end


end
