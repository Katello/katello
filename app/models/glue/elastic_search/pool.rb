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


module Glue::ElasticSearch::Pool
  def self.included(base)

    base.class_eval do
      # Most ActiveRecord models that need to be indexed do so through including IndexedModel. Since not all Pool
      # objects are persisted, this could lead to confusion and unnecessary overhead. (Only Pools referenced by
      # ActivationKeys are stored.) The methods below are the infrastructure for indexing the Pool objects.
      def self.display_attributes
        ['name', 'sla', 'start', 'end', 'consumed', 'product', 'account', 'contract', 'virtual']
      end

      def index_options
        {
          "_type"     => :pool,
          "id"        => @cp_id,
          "name"      => @product_name,
          "name_sort" => @product_name,
          "product_name"=> @product_name,
          "start"     => @start_date,
          "end"       => @end_date,
          "product"   => @product_id,
          "product_id"=> @product_id,
          "account"   => @account_number,
          "contract"  => @contract_number,
          "sla"       => @support_level,
          "support_level"=> @support_level,
          "virtual"   => @virt_only,
          "org"       => @owner["key"],
          "consumed"  => @consumed,
          "quantity"  => @quantity,
          "pool_derived" => @pool_derived,
          "derived"   => @pool_derived,
          "provider_id"=> provider_id,
          "stacking_id" => @stacking_id,
          "multi_entitlement" => @multi_entitlement
        }
      end

      def self.index_mapping
        {
          :pool => {
            :properties => {
              :name         => {:type=>'string', :analyzer=>:kt_name_analyzer},
              :name_sort    => {:type=>'string', :index=>:not_analyzed},
              :product_name => {:type=>'string', :index=>:not_analyzed},
              :all          => {:type=>'string'},
              :begin        => {:type=>'date'},
              :end          => {:type=>'date'},
              :sockets      => {:type=>'long'},
              :ram          => {:type=>'long'},
              :sla          => {:type=>'string'},
              :support_level=> {:type=>'string', :index=>:not_analyzed},
              :org          => {:type=>'string', :index=>:not_analyzed},
              :quantity     => {:type=>'long'},
              :consumed     => {:type=>'long'},
              :pool_derived => {:type=>'boolean', :index=>:not_analyzed},
              :derived      => {:type=>'boolean'},
              :provider_id  => {:type=>'long', :index=>:not_analyzed},
              :stacking_id  => {:type=>'string'},
              :multi_entitlement => {:type=>'boolean'}
            }
          }
        }
      end

      def self.index_pools(pools, clear_filters=nil)
        # Clear previous pools index
        if !clear_filters.nil?
          results = self.search nil, 0, 0, clear_filters
          Tire.index self.index do
            results.each do |result|
              remove :pool, result.id
            end
          end
        end

        json_pools = pools.collect{ |pool|
          pool.as_json.merge(pool.index_options)
        }
        Tire.index self.index do
          create :settings => ::Pool.index_settings, :mappings => ::Pool.index_mapping
          import json_pools
        end if !json_pools.empty?
      end

      def self.search query, start, page_size, filters={}, sort=[:name_sort, "ASC"]
        return [] if !Tire.index(self.index).exists?

        all_rows = query.blank? #if blank, get all rows

        search = Tire.search self.index do
          query do
            if all_rows
              all
            else
              # No default_field is specified to let search span all indexed fields
              string query, {}
            end
          end

          if page_size > 0
           size page_size
           from start
          end

          if filters.has_key?(:org)
            filter :term, :org=>filters[:org]
          end
          if filters.has_key?(:provider_id)
            filter :term, :provider_id=>filters[:provider_id]
          end

          sort { by sort[0], sort[1] } unless !all_rows
        end
        return search.results
      rescue
        return []
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

      def self.index
        "#{Katello.config.elastic_index}_pool"
      end
    end
  end

end
