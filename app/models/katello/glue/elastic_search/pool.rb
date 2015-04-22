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
  module Glue::ElasticSearch::Pool
    # TODO: break this up into modules
    # rubocop:disable MethodLength
    def self.included(base)
      base.class_eval do
        include Glue::ElasticSearch::BackendIndexedModel

        def self.search_type
          :pool
        end

        def self.index
          "#{Katello.config.elastic_index}_pool"
        end

        # Most ActiveRecord models that need to be indexed do so through including IndexedModel. Since not all Pool
        # objects are persisted, this could lead to confusion and unnecessary overhead. (Only Pools referenced by
        # ActivationKeys are stored.) The methods below are the infrastructure for indexing the Pool objects.
        def self.display_attributes
          %w(name sla start end consumed product account contract virtual)
        end

        def index_options
          {
            "_type"     => :pool,
            "id"        => @cp_id,
            "name"      => @product_name,
            "name_sort" => @product_name,
            "product_name" => @product_name,
            "start"     => @start_date,
            "end"       => @end_date,
            "product"   => @product_id,
            "product_id" => @product_id,
            "account"   => @account_number,
            "contract"  => @contract_number,
            "sla"       => @support_level,
            "support_level" => @support_level,
            "virtual"   => @virt_only,
            "org"       => @owner["key"],
            "consumed"  => @consumed,
            "quantity"  => @quantity,
            "pool_derived" => @pool_derived,
            "derived"   => @pool_derived,
            "provider_id" => provider_id,
            "stacking_id" => @stacking_id,
            "multi_entitlement" => @multi_entitlement,

            # TODO: Bug #4005: allow Rabl.render(object, 'something/show') to work
            #       http://projects.theforeman.org/issues/4005#change-12796
            #       Ideally, as_json would be replaced w/ rabl output which would solve this need
            #       for duplication and sync between rabl and elasticsearch indexing.
            #       See also views/katello/api/v2/subscriptions/show.json.rabl
            "cp_id" => @cp_id,
            "start_date" => @start_date,
            "end_date"   => @end_date,
            "account_number" => @account_number,
            "available" => @available,
            "virt_only" => @virt_only,
            "sockets" => @sockets,
            "core"      => @core,
            "ram"       => @ram,
            "instance_multiplier" => @instance_multiplier,
            "provided_products" => @provided_products,
            "systems" => @systems,
            "distributors" => @distributors,
            "account_number"   => @account_number,
            "contract_number"  => @contract_number
          }
        end

        def self.index_mapping
          {
            :pool => {
              :properties => {
                :name         => {:type => 'string', :analyzer => :kt_name_analyzer},
                :name_sort    => {:type => 'string', :index => :not_analyzed},
                :product_name => {:type => 'string', :index => :not_analyzed},
                :all          => {:type => 'string'},
                :begin        => {:type => 'date'},
                :end          => {:type => 'date'},
                :sockets      => {:type => 'long'},
                :ram          => {:type => 'long'},
                :sla          => {:type => 'string'},
                :support_level => {:type => 'string', :index => :not_analyzed},
                :org          => {:type => 'string', :index => :not_analyzed},
                :quantity     => {:type => 'long'},
                :consumed     => {:type => 'long'},
                :pool_derived => {:type => 'boolean', :index => :not_analyzed},
                :derived      => {:type => 'boolean'},
                :provider_id  => {:type => 'long', :index => :not_analyzed},
                :stacking_id  => {:type => 'string'},
                :multi_entitlement => {:type => 'boolean'}
              }
            }
          }
        end

        def self.mapping
          Tire.index(self.index).mapping
        end

        def self.index_pools(pools, clear_filters = nil)
          # Clear previous pools index
          unless clear_filters.nil?
            items = Glue::ElasticSearch::Items.new(Pool)
            options = {
              :filters => clear_filters,
              :load_records? => false
            }
            results, _ = items.retrieve('', 0, options)
            Tire.index self.index do
              results.each do |result|
                remove :pool, result.id
              end
            end
          end

          json_pools = pools.collect do |pool|
            json_pool = pool.as_json
            # Add minimal organization information to elasticsearch since the Tire records are returned
            # as-is to calls for subscriptions index and the json returned by that is meant to have organization
            # details
            organization = pool.organization
            json_pool[:organization] = {:id => organization.id, :name => organization.name, :label => organization.label}
            json_pool[:host] = { :uuid => pool.host.uuid, :name => pool.host.name } if pool.host
            json_pool.merge(pool.index_options)
          end

          unless json_pools.empty?
            Tire.index self.index do
              create :settings => Pool.index_settings, :mappings => Pool.index_mapping
            end unless Tire.index(self.index).exists?

            Tire.index self.index do
              import json_pools
            end

            Tire.index(self.index).refresh
          end
        end

        def self.search(*_args, &block)
          Tire.index self.index do
            create :settings => Pool.index_settings, :mappings => Pool.index_mapping
          end unless Tire.index(self.index).exists?
          Tire.search(self.index, &block).results
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

        def self.expiration_filter(filter_name)
          if filter_name.present?
            if filter_name == 'recent'
              {:range => {:end => {:gte => Date.today - Pool::DAYS_RECENTLY_EXPIRED, :lt => Date.today}}}
            elsif filter_name == 'soon'
              {:range => {:end => {:lte => Date.today + Pool::DAYS_EXPIRING_SOON}}}
            end
          end
        end
      end
    end
  end
end
