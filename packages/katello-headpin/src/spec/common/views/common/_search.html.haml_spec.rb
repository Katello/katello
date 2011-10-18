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

describe "common/_search.html.haml" do

  describe "search history" do

    describe "renders if exists" do
      before (:each) do
        @history_1 = 'recent history 1'
        @history_1_path = '?search='+@history_1+'#'
        @history_2 = 'recent history 2'
        @history_2_path = '?search='+@history_2+'#'
  
        assign(:search_histories, [
               stub_model(SearchHistory, :params => @history_1),
               stub_model(SearchHistory, :params => @history_2)
        ])
      end

      it "displays correct number of entries" do
        view.should_receive(:history_entries).at_least(:once).and_return(2)

        render
        assert_select 'a.recent', {:count => 2}
        assert_select 'a.recent', {:count => 1, :text => @history_1}
        assert_select 'a.recent', {:count => 1, :text => @history_2}
      end

      it "sets URL and display text using search path received" do
        render
        assert_select 'a.recent[href=?]', @history_1_path, {:text => @history_1}
        assert_select 'a.recent[href=?]', @history_2_path, {:text => @history_2}
      end
    end

    it "does not render when it does not exist" do
      render
      assert_select 'a.recent', {:count => 0}
    end
  end

  describe "search favorites" do

    describe "renders if exists" do
      before (:each) do
        @favorite_1 = 'recent favorite 1'
        @favorite_1_path = '?search='+@favorite_1+'#'
        @favorite_2 = 'recent favorite 2'
        @favorite_2_path = '?search='+@favorite_2+'#'

        assign(:search_favorites, [
               stub_model(SearchFavorite, :params => @favorite_1),
               stub_model(SearchFavorite, :params => @favorite_2)
        ])
      end

      it "displays correct number of entries" do
        view.should_receive(:favorite_entries).at_least(:once).and_return(2)

        render
        assert_select 'a.favorite', {:count => 2}
        assert_select 'a.favorite', {:count => 1, :text => @favorite_1}
        assert_select 'a.favorite', {:count => 1, :text => @favorite_2}
      end

      it "sets URL and display text using search path received" do
        render
        assert_select 'a.favorite[href=?]', @favorite_1_path, {:text => @favorite_1}
        assert_select 'a.favorite[href=?]', @favorite_2_path, {:text => @favorite_2}
      end

      it "provides a delete option for each favorite" do
        render
        assert_select 'div.delete#search_favorite_destroy', {:count => 2}
      end
    end

    it "does not render when it does not exist" do
      render
      assert_select 'a.favorite', {:count => 0}
    end
  end

  it "renders link to save a favorite" do
    render
    assert_select 'a.add', {:text => 'Save as Favorite'}
  end

  it "renders link to clear the search" do
    render
    assert_select 'a.clear[href=?]', "?search=", {:text => 'Clear the Search'}
  end

end
