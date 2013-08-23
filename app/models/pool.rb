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

class Pool < ActiveRecord::Base
  include Glue::Candlepin::Pool
  include Glue::ElasticSearch::Pool if Katello.config.use_elasticsearch

  self.table_name = "pools"
  has_many :key_pools, :foreign_key => "pool_id", :dependent => :destroy
  has_many :activation_keys, :through => :key_pools

  # ActivationKey includes the Pool's json in its own'
  def as_json(*args)
    self.remote_data.merge(:cp_id => self.cp_id)
  end

  # If the pool_json is passed in, then candlepin is not hit again to fetch it. This is for the case where
  # prior to this call the pool was already fetched.
  def self.find_pool(cp_id, pool_json=nil)
    pool_json = Resources::Candlepin::Pool.find(cp_id) if !pool_json
    ::Pool.new(pool_json) if !pool_json.nil?
  end

  # Some fields are are not native to the Candlepin object but are useful for searching
  def provider_id
    @cp_provider_id
  end
  def provider_id= cp_id
    @cp_provider_id = cp_id
  end


end
