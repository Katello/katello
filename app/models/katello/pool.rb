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
class Pool < ActiveRecord::Base
  self.include_root_in_json = false

  include Glue::Candlepin::Pool
  include Glue::ElasticSearch::Pool if Katello.config.use_elasticsearch

  self.table_name = "katello_pools"

  # Some fields are are not native to the Candlepin object but are useful for searching
  attr_accessor :cp_provider_id
  alias_method :provider_id, :cp_provider_id
  alias_method :provider_id=, :cp_provider_id=

  DAYS_EXPIRING_SOON = 120
  DAYS_RECENTLY_EXPIRED = 30

  # ActivationKey includes the Pool's json in its own'
  def as_json(*args)
    self.remote_data.merge(:cp_id => self.cp_id)
  end

  # If the pool_json is passed in, then candlepin is not hit again to fetch it. This is for the case where
  # prior to this call the pool was already fetched.
  def self.find_pool(cp_id, pool_json = nil)
    pool_json = Resources::Candlepin::Pool.find(cp_id) if !pool_json
    Katello::Pool.new(pool_json) if !pool_json.nil?
  end

  # Convert active, expiring_soon, and recently_expired into elasticsearch
  # filters and move implementation into ES pool module if performance becomes
  # an issue (though I doubt it will--just sayin')
  def self.active(subscriptions)
    subscriptions.select { |s| s.active }
  end

  def self.expiring_soon(subscriptions)
    subscriptions.select { |s| (s.end_date - Date.today) <= DAYS_EXPIRING_SOON }
  end

  def self.recently_expired(subscriptions)
    today_date = Date.today

    subscriptions.select do |s|
      end_date = s.end_date
      today_date >= end_date && today_date - end_date <= DAYS_RECENTLY_EXPIRED
    end
  end
end
end
