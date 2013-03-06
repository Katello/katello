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


module Glue::ElasticSearch::Items
  extend ActiveSupport::Concern

  module ClassMethods

    # Retrieves items from the Elasticsearch index
    #
    # @param [Hash] search_options
    #
    # @option       search_options :default_field
    #   The field that should be used by the search engine when a user performs
    #   a search without specifying field.
    # @option       search_options :filter
    #   Filter to apply to search. Array of hashes.  Each key/value within the hash
    #   is OR'd, whereas each HASH itself is AND'd together
    # @option search_options [true, false] :load_records
    #   whether or not to load the active record object (defaults to false)
    def items(query, start, sort_by='DESC', sort_order='ASC', search_options={})

      filters       = search_options[:filter] || []
      load_records  = search_options[:load_records] || false
      all_rows      = false
      page_size     = search_options[:page_size]

      if query.nil? || query == ''
        all_rows = true
      elsif search_options[:simple_query] && !Katello.config.simple_search_tokens.any?{|s| search.downcase.match(s)}
        query = search_options[:simple_query]
      end

      # set the query default field, if one was provided.
      query_options = {}
      query_options[:default_field] = search_options[:default_field] unless search_options[:default_field].blank?

      results = []
    
      begin
        results = self.search :load=>false do
          query do
            if all_rows
              all
            else
              string query, query_options
            end
          end

          sort {by sort_by, sort_order.to_s.downcase } if sort_by && sort_order

          filters = [filters] if !filters.is_a? Array
          filters.each{|i|
            filter  :terms, i
          } if !filters.empty?

          size page_size if page_size > 0
          from start
        end

        if load_records
          results = self.where(:id=>results.collect{|r| r.id})
          #set total since results will be just an array
          if results.length != results.length
            Rails.logger.error("Failed to retrieve all #{self} query results " +
                                   "(#{results.length}/#{results.length} found.)")
          end
        else
          results = results
        end

        #get total count
        total = self.search do
          query do
            all
          end
          filters.each{|i|
            filter  :terms, i
          } if !filters.empty?
          size 1
          from 0
        end
        total_count = total.total

      rescue Tire::Search::SearchRequestFailed => e
        Rails.logger.error(e.class)

        total_count = 0
      end

      return results
    end
  end

end
