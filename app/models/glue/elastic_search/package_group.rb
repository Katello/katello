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


module Glue::ElasticSearch::PackageGroup
  def self.included(base)
    base.class_eval do

      def index_options
        {
          "_typedd" => :package_group,
          "name_autocomplete" => name
        }
      end

      def self.index_settings
        {
            "index" => {
                "analysis" => {
                    "filter" => Util::Search::custom_filters,
                    "analyzer" =>Util::Search::custom_analyzers
                }
            }
        }
      end

      def self.index_mapping
        {
          :package_group => {
            :properties => {
              :id            => {:type=>'string', :index=>:not_analyzed},
              :name          => { :type=> 'string', :analyzer=>:kt_name_analyzer},
              :name_autocomplete  => { :type=> 'string', :analyzer=>'autcomplete_name_analyzer'},
              :repoid       => { :type=> 'string', :index=>:not_analyzed},
            }
          }
        }
      end

      def self.index
        "#{Katello.config.elastic_index}_package_group"
      end

      def self.autocomplete_name query, repoid=nil, page_size=15
        return [] if !Tire.index(self.index).exists?

        query = Util::Search::filter_input query
        query = "*" if query == ""
        query = "name_autocomplete:(#{query})"

        search = Tire.search self.index do
          fields [:name]
          query do
            string query
          end

          if repoid
            filter :terms, :repoid => repoid
          end
        end

        to_ret = []
        search.results.each{|pkg|
           to_ret << pkg.name if !to_ret.include?(pkg.name)
           break if to_ret.size == page_size
        }
        return to_ret
      end

      def self.id_search ids
        return Util::Support.array_with_total unless Tire.index(self.index).exists?
        search = Tire.search self.index do
          fields [:id, :name, :repoid, :type]
          query do
            all
          end
          size ids.size
          filter :terms, :id => ids
        end
        search.results
      end

      def self.search query, start, page_size, repoid=nil, sort=[:name_sort, "ASC"], search_mode = :all
        return Util::Support.array_with_total if !Tire.index(self.index).exists?

        all_rows = query.blank? #if blank, get all rows

        search = Tire::Search::Search.new(self.index)

        search.instance_eval do
          query do
            if all_rows
              all
            else
              string query, {:default_field=>'name'}
            end
          end

          if page_size > 0
           size page_size
           from start
          end
          sort { by sort[0], sort[1] } unless !all_rows
        end

        if repoid
          Util::Package.setup_shared_unique_filter([repoid], search_mode, search)
        end

        return search.perform.results
      rescue Tire::Search::SearchRequestFailed => e
        Util::Support.array_with_total
      end

      def self.index_package_groups pkg_grp_ids
        pkg_grps = pkg_grp_ids.collect{ |pkg_grp_id|
          pkg_grp = self.find(pkg_grp_id)
          pkg_grp.as_json.merge(pkg_grp.index_options)
        }
        Tire.index ::PackageGroup.index do
          create :settings => PackageGroup.index_settings, :mappings => PackageGroup.index_mapping
          import pkg_grps
        end unless pkg_grps.empty?
      end

    end
  end
end
