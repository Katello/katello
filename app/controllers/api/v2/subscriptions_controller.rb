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

class Api::V2::SubscriptionsController < Api::V1::SubscriptionsController

  include Api::V2::Rendering

  resource_description do
    description "Systems subscriptions management."
    param :system_id, :identifier, :desc => "System uuid", :required => true

    api_version 'v2'
  end

  api :POST, "/systems/:system_id/subscriptions", "Create a subscription"
  param :subscription, Hash, :required => true, :action_aware => true do
    param :pool, String, :desc => "Subscription Pool uuid", :required => true
    param :quantity, :number, :desc => "Number of subscription to use", :required => true
  end
  def create
    expected_params = params[:subscription].with_indifferent_access.slice(:pool, :quantity)
    raise HttpErrors::BadRequest, _("Please provide pool and quantity") if expected_params.count != 2
    @system.subscribe(expected_params[:pool], expected_params[:quantity])
    respond :resource => @system
  end

  def index
    subscriptions = {
        :subscriptions => @system.consumed_entitlements,
        :subtotal => @system.consumed_entitlements.count,
        :total => @system.consumed_entitlements.count
    }

    respond({:collection => subscriptions})
  end

end
