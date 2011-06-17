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

describe SearchController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods

  before(:each) do
    set_default_locale
    login_user

    controller.stub!(:current_user).and_return(@mock_user)
    
    @from_resource = "/resource"
    # stub out retrieve_path... this method needs specific details from the request which 
    # will not be available from rpec (e.g. HTTP_REFERER)
    controller.stub!(:retrieve_path).and_return(@from_resource)

    @favoriteText = 'provider.name => theBest'
    @searchFavorite = mock_model(SearchFavorite, :params => @favorite)
    @searchFavorites = [@searchFavorite]

    @search_history = mock_model(SearchHistory, :params => 'recent history 1')
    @search_histories = [@search_history]
    controller.stub_chain(:current_user, :search_histories, :where, :order).and_return([])
  end

  describe "GET show" do
    it "retrieves search history" do
      controller.stub_chain(:current_user, :search_histories, :where, :order).and_return(@search_histories)

      get 'show'
      assigns[:search_histories].should == @search_histories
    end

    it "retrieves search favorites" do
      controller.stub_chain(:current_user, :search_favorites, :where, :order).and_return(@search_favorites)

      get 'show'
      assigns[:search_favorites].should == @search_favorites
    end
    
    it "renders search partial" do
      get 'show'
      response.should be_success
      response.should render_template("common/_search")
    end
  end

  describe "POST create favorite" do

    it "successfully creates favorite" do
      # stub query used to determine if favorite already exists
      controller.stub_chain(:current_user, :search_favorites, :where).and_return(@searchFavorites)
      # stub query used to retrieve favorites to be rendered
      controller.stub_chain(:current_user, :search_favorites, :where, :order).and_return(@searchFavorites)

      post :create_favorite, {:favorite => @favoriteText}
      assigns(:search_favorites).should_not be_nil
      assigns(:search_favorites).should eq([@searchFavorite])
      response.should be_success
    end

    it "generates an error notification, if exception raised" do
      # stub query used to retrieve favorites to be rendered
      controller.stub_chain(:current_user, :search_favorites, :where, :order).and_return(@searchFavorites)
      # force an exception when creating the favorite
      controller.stub_chain(:current_user, :search_favorites, :create).and_raise(Exception)

      controller.should_receive(:errors)
      post :create_favorite, {:favorite => @favoriteText}
    end

    it "renders search partial" do
      post :create_favorite, {:favorite => @favoriteText}
      response.should render_template("common/_search")
    end
  end

  describe "DELETE destroy favorite" do

    it "successfully destroys favorite" do
      post :destroy_favorite, {:id => 10}
      response.should be_success
    end

    it "generates an error notification, if exception raised" do
      # stub query used to retrieve favorites to be rendered
      controller.stub_chain(:current_user, :search_favorites, :where, :order).and_return(@searchFavorites)
      # force an exception when creating the favorite
      controller.stub_chain(:current_user, :search_favorites, :destroy).and_raise(Exception)

      controller.should_receive(:errors)
      post :destroy_favorite, {:id => 10}
    end

    it "renders search partial" do
      # stub query used to retrieve favorites to be rendered
      controller.stub_chain(:current_user, :search_favorites, :where, :order).and_return(@searchFavorites)
      controller.stub_chain(:current_user, :search_favorites, :destroy)
      post :destroy_favorite, {"id" => 10}
      response.should render_template("common/_search")
    end
  end

end
