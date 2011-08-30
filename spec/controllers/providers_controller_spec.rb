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
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  
  before(:each) do
    login_user
    set_default_locale
    controller.stub!(:notice)
    controller.stub!(:errors)

    @org = new_test_org
    @org.stub!(:providers).and_return([@provider])
    current_organization=@org
  end

  PROVIDER_NAME = "a name"
  ANOTHER_PROVIDER_NAME = "another name"

  let(:to_create) do
    {
      :name => PROVIDER_NAME,
      :description => "a description",
      :repository_url => "https://some.url",
      :provider_type => Provider::REDHAT,
       :organization => @org
    }
  end

  describe "update a provider subscriptions" do
    before(:each) do
      @provider = Provider.create!(to_create)
      Candlepin::Owner.should_receive(:import).once.and_return("")
      Candlepin::Owner.stub!(:pools).and_return({})
    end

    it "should update a provider subscription" do
      test_export = File.new("#{Rails.root}/spec/controllers/export.zip")
      contents = {:contents => test_export}
      id = @provider.id.to_s
      post 'update_subscriptions', {:id => id, :provider => contents}
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
      let(:action) {:index}
      let(:req) { get 'index' }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :providers, @provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      let(:on_success) do
        assigns(:providers).should_not include @provider2
        assigns(:providers).should include @provider
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
