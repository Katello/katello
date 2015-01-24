#
# Copyright 2014 Red Hat, Inc.
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
  describe DashboardController do
    include LocaleHelperMethods

    before :each do
      setup_controller_defaults
      @organization = get_organization
      @controller.stubs(:current_organization).returns(@organization)

      Resources::Candlepin::OwnerInfo.stubs(:find).returns({})
      Katello::HostCollection.any_instance.stubs(:errata).returns([])
    end

    describe "GET 'index'" do
      it "should be successful" do
        FactoryGirl.create(:host) # Dashboard needs a host or it renders differently
        @controller.expects(:render)
        get 'index'
        must_respond_with(:success)
      end
    end

    describe "GET host_collections" do
      it "should be successful" do
        @controller.expects(:render).twice
        get 'host_collections'
        must_respond_with(:success)
      end

      it "should render host collections partial" do
        get 'host_collections'
        must_render_template(:partial => "_host_collections")
      end
    end

    describe "GET content_views" do
      it "should be successful" do
        @controller.expects(:render).twice
        get 'content_views'
        must_respond_with(:success)
      end

      it "should render content views partial" do
        get 'content_views'
        must_render_template(:partial => "_content_views")
      end
    end
  end
end
