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
describe SyncManagementController do

  include LocaleHelperMethods
  include AuthorizationHelperMethods
  include ProductHelperMethods
  include OrchestrationHelper
  include OrganizationHelperMethods

  before (:each) do
    setup_controller_defaults
  end

  describe "Environment is set (katello)" do
    before (:each) do
      Katello.pulp_server.extensions.repository.stubs(:search_by_repository_ids).returns([])
      @organization = get_organization
      @controller.stubs(:current_organization).returns(@organization)
      @library = @organization.library
      @organization.stubs(:library).returns(@library)
      Glue::Pulp::Repos.stubs(:prepopulate!).returns({})
      @controller.stubs(:get_product_info).returns({})

      @library.stubs(:products).returns(
          OpenStruct.new.tap do |os|
            def os.readable(org); []; end
            def os.syncable(org); []; end
          end
      )
      Provider.stubs(:any_readable?).returns(true)
    end

    describe "GET 'index'" do
      it "should be successful" do
        get 'index'
        must_respond_with(:success)
      end
    end

    describe "GET 'manage'" do
      it "should be successful" do
        @controller.expects(:render)
        get 'manage'
        must_respond_with(:success)
      end
    end
  end

  describe "rules" do
    before (:each) do
      @organization = new_test_org
      @product = new_test_product @organization, @organization.library
      Provider.stubs(:find).returns @product.provider
      Product.stubs(:find).returns @product
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
end
