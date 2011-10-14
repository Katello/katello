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

describe SyncManagementController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include AuthorizationHelperMethods
  include ProductHelperMethods
  include OrchestrationHelper


  
  before (:each) do
    login_user
    set_default_locale
  end

  describe "GET 'index'" do
    before (:each) do
      setup_current_organization
      @locker = KTEnvironment.new
      @mock_org.stub!(:locker).and_return(@locker)
      @locker.stub!(:products).and_return(OpenStruct.new(:readable => [], :syncable=>[]))
    end


    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end


  describe "rules" do
    before (:each) do
      @organization = new_test_org
      @product = new_test_product @organization, @organization.locker
      Provider.stub(:find).and_return @product.provider
      Product.stub(:find).and_return @product
      
    end
    describe "GET index" do

      let(:action) {:index}
      let(:req) { get 'index' }
      let(:authorized_user) do
        
        user_with_permissions { |u| u.can(:read, :providers, @product.provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end


      it_should_behave_like "protected action"
    end

    describe "sync" do

      let(:action) {:sync}
      let(:req) do
        put 'sync', :repo => {@product.repos(@organization.locker).first.id=>@product.id}, :name=>"barfoo", :product_id=>@product.id
      end
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:sync, :organizations, nil, @organization) }
      end
      let(:unauthorized_user) do
         user_with_permissions { |u| u.can(:read, :providers, @product.provider.id, @organization) }
      end
      it_should_behave_like "protected action"
    end
  end




end
