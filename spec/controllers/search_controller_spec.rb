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
  describe SearchController do
    include LocaleHelperMethods
    include OrganizationHelperMethods

    before(:each) do
      setup_controller_defaults
      set_default_locale

      @user = users(:restricted)

      @organization = get_organization
      @controller.stubs(:current_organization).returns(@organization)

      @from_resource = "/resource"
      # stub out retrieve_path... this method needs specific details from the request which
      # will not be available from rpec (e.g. HTTP_REFERER)
      @controller.stubs(:retrieve_path).returns(@from_resource)

      @search_favorite = SearchFavorite.create!(:params => @favorite, :user => @user, :path => @from_resource)
      @search_favorites = [@search_favorite]

      @search_history = SearchHistory.create!(:params => 'recent history 1', :user => @user, :path => @from_resource)
      @search_histories = [@search_history]

      @user.search_histories = @search_histories
      @user.search_favorites = @search_favorites
      @controller.stubs(:current_user).returns(@user)
    end

    describe "GET show" do
      it "retrieves search history" do
        get 'show'
        assigns[:search_histories].must_equal @search_histories
      end

      it "retrieves search favorites" do
        get 'show'
        assigns[:search_favorites].must_equal @search_favorites
      end

      it "renders search partial" do
        get 'show'
        must_respond_with(:success)
        must_render_template("katello/common/_search")
      end
    end

    describe "POST create favorite" do
      it "successfully creates favorite" do
        post :create_favorite, :favorite => @favoriteText
        @user.search_favorites.wont_be_empty
        must_respond_with(:success)
      end

      it "renders search partial" do
        post :create_favorite, :favorite => @favoriteText
        must_render_template("katello/common/_search")
      end
    end

    describe "DELETE destroy favorite" do
      it "successfully destroys favorite" do
        post :destroy_favorite, :id => @search_favorite.id
        must_respond_with(:success)
      end

      it "generates an error notification, if exception raised" do
        must_notify_with(:error)
        post :destroy_favorite, :id => 10
      end

      it "renders search partial" do
        post :destroy_favorite, :id => @search_favorite.id
        must_render_template("katello/common/_search")
      end
    end
  end
end
