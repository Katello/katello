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

require 'spec_helper'

describe SyncManagementController, :katello => true do
  include LoginHelperMethods
  include LocaleHelperMethods
  include AuthorizationHelperMethods
  include ProductHelperMethods
  include OrchestrationHelper

  before (:each) do
    login_user
    set_default_locale
  end

  context "Environment is set" do
    before (:each) do
      Runcible::Extensions::Repository.stub(:search_by_repository_ids).and_return([])
      setup_current_organization
      @library = KTEnvironment.new
      @mock_org.stub!(:library).and_return(@library)
      @library.stub!(:products).and_return(
          OpenStruct.new.tap do |os|
            def os.readable(org); []; end
            def os.syncable(org); []; end
          end
      )
      Provider.stub!(:any_readable?).and_return(true)
    end

    describe "GET 'index'" do
      it "should be successful" do
        get 'index'
        response.should be_success
      end
    end

    describe "GET 'manage'" do
      it "should be successful" do
        get 'manage'
        response.should be_success
      end
    end
  end

  describe "rules" do
    before (:each) do
      @organization = new_test_org
      @product = new_test_product @organization, @organization.library
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
        put 'sync', :repoids => [@product.repos(@organization.library).first.id]
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
