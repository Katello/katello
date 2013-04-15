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


module Glue
  module ElasticSearch
    class Items

      attr_accessor :obj_class, :query_string, :results, :total, :filters

      def initialize(obj_class)
        @obj_class    = obj_class
        @query_string = query_string
        @results      = []
        @filters      = []
      end

      # Retrieves items from the Elasticsearch index
      #
      # @param [String] query_string
      #   what the class should be searched by, e.g. name:foo*
      # @param [Integer] start
      #   the start position to begin searching from, used for pagination
      # @param [Hash] search_options optional search parameters, see options
      # @option       search_options :default_field
      #   The field that should be used by the search engine when a user performs
      #   a search without specifying field.
      # @option       search_options :page_size
      #   Specifies the number of results to return
      # @option       search_options :sort_by
      #   The model field on which to sort
      # @option       search_options :sort_order
      #   The order to sort on, one of DESC or ASC
      # @option       search_options :filter
      #   Filter to apply to search. Array of hashes.  Each key/value within the hash
      #   is OR'd, whereas each HASH itself is AND'd together
      # @option search_options [true, false] :load_records?
      #   whether or not to load the active record object (defaults to false)
      def retrieve(query_string, start=0, search_options={})

        @query_string = query_string
        @filters      = search_options[:filter] || []
        start         = start || 0
        all_rows      = false
        sort_by       = search_options[:sort_by] || 'name'
        sort_order    = search_options[:sort_order] || 'ASC'
        total_count   = 0

        # set the query default field, if one was provided.
        query_options = {}
        query_options[:default_field] = search_options[:default_field] || 'name'

        if @query_string.nil? || @query_string == ''
          all_rows = true
        elsif search_options[:simple_query] && !Katello.config.simple_search_tokens.any?{|s| search.downcase.match(s)}
          @query_string = search_options[:simple_query]
        end

        total_count = total_items
        page_size = search_options[:page_size] || total_count
        filters = @filters

        @results = @obj_class.search :load=>false do
          query do
            if all_rows
              all
            else
              string query_string, query_options
            end
          end

          sort {by sort_by, sort_order.to_s.downcase } if sort_by && sort_order

          filters = [filters] if !filters.is_a? Array
          filters.each{ |i| filter  :terms, i } if !filters.empty?

          size page_size
          from start
        end

        total_count = @results.total

        if search_options[:load_records?]
          @results = load_records
        end

      rescue Tire::Search::SearchRequestFailed => e
        Rails.logger.error(e.class)

        @results = []
      ensure
        return @results, total_count
      end

      # Loads the ActiveRecord objects from the database that match
      # the results returned by Elasticsearch
      #
      # @return [Array] a list of ActiveRecord objects
      def load_records
        collection = @obj_class.where(:id => @results.collect{|r| r.id})

        #set total since @items will be just an array
        @total = @results.empty? ? 0 : @results.total
        if @total != collection.length
          Rails.logger.error("Failed to retrieve all #{@obj_class} search results " +
                                 "(#{collection.length}/#{@results.length} found.)")
        end

        @results = collection
        return @results
      end

      # Retrieves the total number of items based on a set of filters
      #
      # @return [Integer] the total number of objects that meet the filters
      def total_items
        @total = 0
        filters = @filters

        results = @obj_class.search do
          query do
            all
          end

          filters.each{ |i| filter  :terms, i } if !filters.empty?

          size 1
          from 0
        end

        @total = results.total

      rescue Tire::Search::SearchRequestFailed => e
        Rails.logger.error(e.class)
      rescue => e
        puts e
      ensure
        return @total
      end

    end
  end
end
