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

module Glue::ElasticSearch::PuppetModule
  def self.included(base)
    base.class_eval do

      def index_options
        {
          "_type"             => :puppet_module,
          "name_sort"         => name.downcase,
          "name_autocomplete" => name,
          "author_autocomplete" => author,
          "sortable_version"  => sortable_version
        }
      end

      def self.index_settings
        {
          "index" => {
            "analysis" => {
              "filter" => Util::Search::custom_filters,
              "analyzer" => Util::Search::custom_analyzers
            }
          }
        }
      end

      def self.index_mapping
        {
          :puppet_module => {
            :properties => {
              :id               => { :type => 'string', :index    => :not_analyzed },
              :name             => { :type => 'string', :analyzer => :kt_name_analyzer },
              :name_sort        => { :type => 'string', :index    => :not_analyzed },
              :sortable_version => { :type => 'string', :index    => :not_analyzed },
              :repoids          => { :type => 'string', :index    => :not_analyzed }
            }
          }
        }
      end

      def self.index
        "#{Katello.config.elastic_index}_puppet_module"
      end

      def self.autocomplete_name(query, repoids = nil, page_size = 15)
        return [] if !Tire.index(self.index).exists?

        query = autocomplete_field_query("name", query)
        field_search(query, :name, repoids, page_size)
      end

      def self.autocomplete_author(query, repoids = nil, page_size = 15, name = nil)
        return [] if !Tire.index(self.index).exists?

        query = autocomplete_field_query("author", query)
        if name.present?
          query += " AND #{autocomplete_field_query("name", name)}"
        end

        field_search(query, :author, repoids, page_size)
      end

      def self.id_search(ids)
        return Util::Support.array_with_total unless Tire.index(self.index).exists?
        search = Tire.search self.index do
          fields [:id, :name, :repoids]
          query do
            all
          end
          size ids.size
          filter :terms, :id => ids
        end
        search.results
      end

      def self.search(query, options = {})
        options = {:start => 0,
                   :page_size => 10,
                   :repoids => nil,
                   :sort => [:name_sort, "ASC"],
                   :search_mode => :all,
                   :default_field => 'name',
                   :filters => nil}.merge(options)

        if !Tire.index(self.index).exists? || (options[:repoids] && options[:repoids].empty?)
          return Util::Support.array_with_total
        end

        all_rows = query.blank? #if blank, get all rows
        search = Tire::Search::Search.new(self.index)
        search.instance_eval do
          query do
            if all_rows
              all
            else
              string query, { :default_field => options[:default_field] }
            end
          end

          if options[:page_size] > 0
           size options[:page_size]
           from options[:start]
          end
          sort { by options[:sort][0], options[:sort][1] } unless !all_rows
        end

        if options[:filters]
          options[:filters].each do |filter|
            search.filter(filter.keys.first, filter.values.first)
          end
        end

        if options[:repoids]
          Util::Package.setup_shared_unique_filter(options[:repoids], options[:search_mode], search)
        end

        return search.perform.results
      rescue Tire::Search::SearchRequestFailed => e
        Util::Support.array_with_total
      end

      def self.index_puppet_modules(puppet_module_ids)
        puppet_modules = puppet_module_ids.collect{ |module_id|
          puppet_module = self.find(module_id)
          puppet_module.as_json.merge(puppet_module.index_options)
        }

        unless puppet_modules.empty?
          Tire.index ::PuppetModule.index do
            create :settings => PuppetModule.index_settings, :mappings => PuppetModule.index_mapping
          end unless Tire.index(::PuppetModule.index).exists?

          Tire.index ::PuppetModule.index do
            import puppet_modules
          end
        end
      end

      private

      def self.field_search(query, field, repoids=nil, page_size=15)
        search = Tire.search(self.index) do
          fields [field]
          query do
            string query
          end

          if repoids
            filter :terms, :repoids => repoids
          end
        end

        return search.results.map(&field).uniq[0, page_size.to_i]
      end

      def self.autocomplete_field_query(field, value)
        value = "*" if value.blank?
        value = Util::Search.filter_input(value)
        "#{field}_autocomplete:(#{value})"
      end

    end
  end
end
