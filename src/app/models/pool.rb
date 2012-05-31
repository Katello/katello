#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'util/search'

class Pool < ActiveRecord::Base
  include Glue::Candlepin::Pool
  include IndexedModel

  set_table_name "pools"
  has_many :key_pools, :foreign_key => "pool_id", :dependent => :destroy
  has_many :activation_keys, :through => :key_pools

  def as_json(*args)
    {:cp_id => self.cp_id}
  end

  index_options :extended_json => :extended_json,
      :display_attrs => ['name', 'sla', 'start', 'end', 'consumed', 'product', 'account', 'contract', 'virtual']

  def extended_json
    {
      "_type"     => :pool,
      "id"        => @cp_id,
      "name"      => @productName,
      "name_sort" => @productName,
      "start"     => @startDate,
      "end"       => @endDate,
      "product"   => @productId,
      "account"   => @accountNumber,
      "contract"  => @contractNumber,
      "sla"       => @supportLevel,
      "virtual"   => @virtOnly,
      "org"       => @owner["key"]
    }
  end

  def self.index_mapping
    {
      :pool => {
        :properties => {
          :name         => {:type=>'string', :analyzer=>:kt_name_analyzer},
          :name_sort    => {:type=>'string', :index=>:not_analyzed},
          :all          => {:type=>'string'},
          :begin        => {:type=>'date'},
          :end          => {:type=>'date'},
          :sockets      => {:type=>'long'},
          :sla          => {:type=>'string'},
          :org          => {:type=>'string', :index=>:not_analyzed}
        }
      }
    }
  end

  def self.index_settings
    {
        "index" => {
            "analysis" => {
                "filter" => {
                    "ngram_filter"  => {
                        "type"      => "edgeNGram",
                        "side"      => "front",
                        "min_gram"  => 1,
                        "max_gram"  => 30
                    }
                },
                "analyzer" => Katello::Search::custom_analyzers
            }
        }
    }
  end

  def self.index
    "#{AppConfig.elastic_index}_pool"
  end

  def self.find_pool(cp_id, pool_json=nil)
    pool_json = Resources::Candlepin::Pool.find(cp_id) if !pool_json
    Pool.new(pool_json) if not pool_json.nil?
  end

  def self.index_pools cp_pools
    pools = []
    json_pools = cp_pools.collect{ |cp_pool|
      pool = self.find_pool(cp_pool['id'], cp_pool)
      pools << pool
      pool.to_indexed_json
    }
    Tire.index self.index do
      create :settings => Pool.index_settings, :mappings => Pool.index_mapping
      import json_pools
    end if !json_pools.empty?

    pools
  end

  def self.search org_key, query, start, page_size, sort=[:name_sort, "ASC"]
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

      if org_key
        filter :term, 'org'=>org_key
      end

      sort { by sort[0], sort[1] } unless !all_rows
    end
    return search.results
  rescue
    return []
  end

end
