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
  module Glue::ElasticSearch::Package
    # TODO: break up into modules
    def self.included(base) # rubocop:disable MethodLength
      base.class_eval do
        include Glue::ElasticSearch::BackendIndexedModel

        def index_options
          {
            "_type" => self.class.search_type,
            "nvrea_sort" => nvrea.downcase,
            "nvra_sort" => nvra.downcase,
            "nvra" => nvra,
            "nvrea" => nvrea,
            "nvrea_autocomplete" => nvrea,
            "sortable_version" => sortable_version,
            "sortable_release" => sortable_release,
            "name_autocomplete" => name
          }
        end

        def self.index_settings
          {
            "index" => {
              "analysis" => {
                "filter" => Util::Search.custom_filters,
                "analyzer" => Util::Search.custom_analyzers
              }
            }
          }
        end

        def self.search_type
          :package
        end

        def self.index_mapping
          {
            :package => {
              :properties => {
                :id            => {:type => 'string', :index => :not_analyzed},
                :name          => { :type => 'string', :analyzer => :kt_name_analyzer},
                :name_autocomplete  => { :type => 'string', :analyzer => 'autcomplete_name_analyzer'},
                :nvrea_autocomplete  => { :type => 'string', :analyzer => 'autcomplete_name_analyzer'},
                :nvrea         => { :type => 'string', :analyzer => :kt_name_analyzer},
                :nvrea_sort    => { :type => 'string', :index => :not_analyzed },
                :nvra         => { :type => 'string', :analyzer => :kt_name_analyzer},
                :filename     => { :type => 'string', :analyzer => :kt_name_analyzer},
                :nvra_sort    => { :type => 'string', :index => :not_analyzed },
                :repoids       => { :type => 'string', :index => :not_analyzed},
                :sortable_version => { :type => 'string', :index => :not_analyzed },
                :sortable_release => { :type => 'string', :index => :not_analyzed }
              }
            }
          }
        end

        def self.index
          "#{Katello.config.elastic_index}_package"
        end

        def self.autocomplete_name(query, repoids = nil, page_size = 15)
          return [] unless index_exists?

          query = Util::Search.filter_input query
          query = "*" if query == ""
          query = "name_autocomplete:(#{query})"

          search = Tire.search self.index do
            fields [:name]
            query do
              string query
            end

            if repoids
              filter :terms, :repoids => repoids
            end
          end

          to_ret = []
          search.results.each do |pkg|
            to_ret << pkg.name unless to_ret.include?(pkg.name)
            break if to_ret.size == page_size
          end
          return to_ret
        end

        def self.autocomplete_nvrea(query, repoids = nil, page_size = 15)
          return Util::Support.array_with_total unless index_exists?

          query = Util::Search.filter_input query
          query = "*" if query == ""
          query = "name_autocomplete:(#{query})"

          search = Tire.search self.index do
            fields [:nvrea]
            query do
              string query
            end
            size page_size

            if repoids
              filter :terms, :repoids => repoids
            end
          end

          search.results
        end

        def self.id_search(ids)
          return Util::Support.array_with_total unless index_exists?
          search = Tire.search self.index do
            fields [:id, :name, :nvrea, :repoids, :type, :filename, :checksum]
            query do
              all
            end
            size ids.size
            filter :terms, :id => ids
          end
          search.results
        end

        def self.package_count(repos)
          return Util::Support.array_with_total unless index_exists?
          repo_ids = repos.map(&:pulp_id)
          search = Package.search do
            query do
              all
            end
            fields [:id]
            size 1
            filter :terms, :repoids => repo_ids
          end
          search.total
        end

        def self.mapping
          Tire.index(self.index).mapping
        end

        def self.search(_options = {}, &block)
          Tire.search(self.index, &block).results
        end

        # TODO: break up method
        # rubocop:disable MethodLength
        def self.legacy_search(query, start = 0, page_size = 15, repoids = nil, sort = [:nvrea_sort, "asc"],
                        search_mode = :all, default_field = 'nvrea', filters = [])
          if !index_exists? || (repoids && repoids.empty?)
            return Util::Support.array_with_total
          end

          all_rows = query.blank? #if blank, get all rows

          search = Tire::Search::Search.new(self.index)

          search.instance_eval do
            fields [:id, :name, :nvrea, :repoids, :description, :filename]

            query do
              if all_rows
                all
              else
                string query, :default_field => default_field
              end
            end

            if page_size > 0
              size page_size
              from start
            end
            sort { by sort[0], sort[1] } if all_rows
          end

          if filters
            filters.each do |filter|
              search.filter(filter.keys.first, filter.values.first)
            end
          end

          if repoids
            Util::Package.setup_shared_unique_filter(repoids, search_mode, search)
          end

          return search.perform.results
        rescue Tire::Search::SearchRequestFailed
          Util::Support.array_with_total
        end

        def self.add_indexed_repoid(pkg_ids, repoid)
          unless repoid.is_a?(Array)
            repoid = [repoid]
          end
          update_array(pkg_ids, 'repoids', repoid, [])
        end

        def self.remove_indexed_repoid(pkg_ids, repoid)
          unless repoid.is_a?(Array)
            repoid = [repoid]
          end
          update_array(pkg_ids, 'repoids', [], repoid)
        end

        def self.index_packages(pkg_ids)
          pkgs = pkg_ids.collect do |pkg_id|
            pkg = self.find(pkg_id)
            pkg.as_json.except('changelog', 'files', 'filelist').merge(pkg.index_options)
          end

          unless pkgs.empty?
            create_index
            Tire.index Package.index do
              import pkgs
            end
            Tire.index(Package.index).refresh
          end
        end
      end
    end
  end
end
