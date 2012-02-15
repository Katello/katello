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

class Api::SubscriptionsController < Api::ApiController
  respond_to :json

  before_filter :find_system, :only => [:create, :index, :destroy, :destroy_all, :destroy_by_serial]
  before_filter :authorize

  def rules
    list_subscriptions = lambda { @system.readable? }
    subscribe = lambda { @system.editable? }

    {
      :create => subscribe,
      :index => list_subscriptions,
      :destroy => subscribe,
      :destroy_all => subscribe,
      :destroy_by_serial => subscribe
    }
  end

  def index
    render :json => { :entitlements => @system.consumed_entitlements }
  end

  def create
    expected_params = params.with_indifferent_access.slice(:pool, :quantity)
    raise HttpErrors::BadRequest, _("Please provide pool and quantity") if expected_params.count != 2
    @system.subscribe(expected_params[:pool], expected_params[:quantity])
    render :json => @system.to_json
  end

  def destroy
    expected_params = params.with_indifferent_access.slice(:id)
    raise HttpErrors::BadRequest, _("Please provide entitlement id") if expected_params.count != 1
    @system.unsubscribe(expected_params[:id])
    render :json => @system.to_json
  end

  def destroy_all
    @system.unsubscribe_all
    render :json => @system.to_json
  end

  def destroy_by_serial
    expected_params = params.with_indifferent_access.slice(:serial_id)
    raise HttpErrors::BadRequest, _("Please provide serial id") if expected_params.count != 1
    @system.unsubscribe_by_serial(expected_params[:serial_id])
    render :json => @system.to_json
  end

  private

  def find_system
    @system = System.first(:conditions => {:uuid => params[:system_id]})
    raise HttpErrors::NotFound, _("Couldn't find system '#{params[:system_id]}'") if @system.nil?
    @system
  end

end
