#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

class SubscriptionsController < ApplicationController

  def rules
    {
      :index => lambda{current_organization && current_organization.readable?}
    }
  end

  def section_id
    'orgs'
  end

  def index
    # Raw candlepin pools
    cp_pools = Resources::Candlepin::Owner.pools(current_organization.cp_key)
    if cp_pools
      # Pool objects
      @subscriptions = cp_pools.collect {|cp_pool| ::Pool.find_pool(cp_pool['id'], cp_pool)}
      # Index pools
      ::Pool.index_pools(@subscriptions) if @subscriptions.length > 0
    else
      @subscriptions = []
    end

    @subscriptions
  end
end
