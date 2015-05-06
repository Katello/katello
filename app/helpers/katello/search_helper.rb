module Katello
  module SearchHelper
    def max_search_history
      5
    end

    def max_search_favorites
      5
    end

    def history_entries
      @search_histories.length < max_search_history ? @search_histories.length : max_search_history
    end

    def favorite_entries
      @search_favorites.length < max_search_favorites ? @search_favorites.length : max_search_favorites
    end

    def search_string(search)
      "?search=#{search.params}#" unless search.nil? || search.params.nil?
    end
  end
end
