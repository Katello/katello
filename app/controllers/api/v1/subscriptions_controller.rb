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

class Api::V1::SubscriptionsController < Api::V1::ApiController

  resource_description do
    description "Systems subscriptions management."
    param :system_id, :identifier, :desc => "System uuid", :required => true

    api_version 'v1'
    api_version 'v2'
  end

  respond_to :json

  before_filter :find_system, :only => [:create, :index, :destroy, :destroy_all, :destroy_by_serial]
  before_filter :authorize

  def rules
    list_subscriptions = lambda { @system.readable? }
    subscribe          = lambda { @system.editable? }

    {
        :create            => subscribe,
        :index             => list_subscriptions,
        :destroy           => subscribe,
        :destroy_all       => subscribe,
        :destroy_by_serial => subscribe
    }
  end

  api :GET, "/systems/:system_id/subscriptions", "List subscriptions"
  def index
    respond :collection => { :entitlements => @system.consumed_entitlements }
  end

  api :POST, "/systems/:system_id/subscriptions", "Create a subscription"
  param :pool, String, :desc => "Subscription Pool uuid", :required => true
  param :quantity, :number, :desc => "Number of subscription to use", :required => true
  def create
    expected_params = params.with_indifferent_access.slice(:pool, :quantity)
    raise HttpErrors::BadRequest, _("Please provide pool and quantity") if expected_params.count != 2
    @system.subscribe(expected_params[:pool], expected_params[:quantity])
    respond :resource => @system
  end

  api :DELETE, "/systems/:system_id/subscriptions/:id", "Delete a subscription"
  param :id, :number, :desc => "Entitlement id"
  def destroy
    expected_params = params.with_indifferent_access.slice(:id)
    raise HttpErrors::BadRequest, _("Please provide subscription ID") if expected_params.count != 1
    @system.unsubscribe(expected_params[:id])
    respond_for_show :resource => @system
  end

  api :DELETE, "/systems/:system_id/subscriptions", "Delete all system subscriptions"
  def destroy_all
    @system.unsubscribe_all
    respond_for_show :resource => @system
  end

  api :DELETE, "/systems/:system_id/subscriptions/serials/:serial_id", "Delete a subscription by serial id"
  param :serial_id, String, :desc => "Subscription serial id"
  def destroy_by_serial
    expected_params = params.with_indifferent_access.slice(:serial_id)
    raise HttpErrors::BadRequest, _("Please provide serial ID") if expected_params.count != 1
    @system.unsubscribe_by_serial(expected_params[:serial_id])
    respond_for_show :resource => @system
  end

  private

  def find_system
    @system = System.first(:conditions => { :uuid => params[:system_id] })
    raise HttpErrors::NotFound, _("Couldn't find system '%s'") % params[:system_id] if @system.nil?
    @system
  end

end
