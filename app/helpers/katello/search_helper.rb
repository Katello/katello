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
