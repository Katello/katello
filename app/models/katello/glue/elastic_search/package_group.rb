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
  module Glue::ElasticSearch::PackageGroup
    def self.included(base)
      base.class_eval do

        def index_options
          {
            "_type" => :package_group,
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
                :package_group_id => {:type=>'string', :index=>:not_analyzed},
                :name          => { :type=> 'string', :analyzer=>:kt_name_analyzer},
                :name_sort    => { :type => 'string', :index=> :not_analyzed },
                :repo_id       => { :type=> 'string', :index=>:not_analyzed},
              }
            }
          }
        end

        def self.index
          "#{Katello.config.elastic_index}_package_group"
        end

        def self.id_search ids
          return Util::Support.array_with_total unless Tire.index(self.index).exists?
          search = Tire.search self.index do
            fields [:id, :name, :repo_id]
            query do
              all
            end
            size ids.size
            filter :terms, :id => ids
          end
          search.results
        end

        def self.search query, start, page_size, repoid=nil, sort=[:name_sort, "ASC"], default_field = 'name'
          return Util::Support.array_with_total if !Tire.index(self.index).exists?

          all_rows = query.blank? #if blank, get all rows

          search = Tire.search self.index do
            query do
              if all_rows
                all
              else
                string query, {:default_field=>default_field}
              end
            end

            if page_size > 0
             size page_size
             from start
            end

            if repoid
              filter :term, :repo_id => repoid
            end
            sort { by sort[0], sort[1] } unless !all_rows
          end


          return search.results
        rescue Tire::Search::SearchRequestFailed => e
          Util::Support.array_with_total
        end

        def self.index_package_groups pkg_grp_ids
          pkg_grps = pkg_grp_ids.collect{ |pkg_grp_id|
            pkg_grp = self.find(pkg_grp_id)
            pkg_grp.as_json.merge(pkg_grp.index_options)
          }

          unless pkg_grps.empty?
            Tire.index ::PackageGroup.index do
              create :settings => PackageGroup.index_settings, :mappings => PackageGroup.index_mapping
            end unless Tire.index(::PackageGroup.index).exists?

            Tire.index ::PackageGroup.index do
              import pkg_grps
            end
          end
        end

      end
    end
  end
end
