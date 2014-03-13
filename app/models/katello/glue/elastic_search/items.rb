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

module Katello
module Glue
  module ElasticSearch
    class Items

      attr_accessor :obj_class, :query_string, :results, :total, :filters, :search_options
      alias_method :model=, :obj_class=

      def initialize(obj_class = nil)
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
      # @option       search_options :per_page
      #   Specifies the number of results to return
      # @option       search_options :sort_by
      #   The model field on which to sort
      # @option       search_options :sort_order
      #   The order to sort on, one of DESC or ASC
      # @option       search_options :filters
      #   Filter to apply to search. Array of hashes.  Each key/value within the hash
      #   is OR'd, whereas each HASH itself is AND'd together
      # @option search_options [true, false] :load_records?
      #   whether or not to load the active record object (defaults to false)
      # TODO: break up method
      # rubocop:disable MethodLength
      def retrieve(query_string = nil, offset = 0, search_options = {})
        search_options = @search_options || search_options.with_indifferent_access
        query_string = query_string || @query_string
        @filters      = search_options[:filters] || @filters
        start         = offset || search_options[:offset] || 0
        all_rows      = false
        sort_by       = search_options.fetch(:sort_by, 'name_sort')
        sort_order    = search_options[:sort_order] || 'ASC'
        total_count   = 0

        sort_by = format_sort(sort_by)

        # set the query default field, if one was provided.
        query_options = {}
        query_options[:default_field] = search_options[:default_field] || 'name'

        if query_string.blank?
          all_rows = true
        elsif search_options[:simple_query] && !Katello.config.simple_search_tokens.any?{|s| search.downcase.match(s)}
          query_string  = search_options[:simple_query]
        end

        page_size = if search_options[:page]
                      search_options[:per_page] || ::Setting::General.entries_per_page
                    else
                      search_options[:per_page] || total_items
                    end
        filters = @filters
        filters = [filters] if !filters.is_a? Array

        @results = @obj_class.search(:load => false) do
          query do
            if all_rows
              all
            else
              string query_string, query_options
            end
          end
          sort {by sort_by, sort_order.to_s.downcase } if sort_by && sort_order

          fields [:id] if options[:load_records?]

          filter :and, filters if filters.any?

          size page_size
          from start
        end

        total_count = @results.total

        if search_options[:load_records?]
          @results = load_records
        else
          @results = @results.results
        end

        return @results, total_count
      rescue Tire::Search::SearchRequestFailed => e
        Rails.logger.error(e.class)

        @results = []
        return @results, total_count
      end

      # Loads the ActiveRecord objects from the database that match
      # the results returned by Elasticsearch
      #
      # @return [Array] a list of ActiveRecord objects
      def load_records
        collection = @obj_class.where(:id => @results.collect{|r| r.id}).
            order(@results.collect{|r| "id = #{r.id} DESC"})

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
        filters = [filters] if !filters.is_a? Array

        results = @obj_class.search do
          query do
            all
          end

          filter :and, filters if filters.any?

          size 1
          from 0
        end

        @total = results.total

        return @total
      rescue Tire::Search::SearchRequestFailed => e
        Rails.logger.error(e.class)
        return @total
      rescue => e
        puts e
        return @total
      end

      private

      def format_sort(sort_by)
        mapping = @obj_class.mapping || {}
        if mapping[sort_by.to_sym] && mapping[sort_by.to_sym][:type] == 'date'
          sort_by
        else
          sort_by + '_sort' if !sort_by.to_s.include?('_sort')
        end
      end

    end
  end
end
end
