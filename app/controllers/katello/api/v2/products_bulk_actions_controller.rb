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
  class Api::V2::ProductsBulkActionsController < Api::V2::ApiController

    before_filter :find_organization
    before_filter :find_products
    before_filter :authorize

    def rules
      deletable = lambda{ Product.assert_deletable(@products) }
      syncable = lambda{ Product.assert_syncable(@products) }
      editable = lambda{ Product.assert_editable(@products) }

      hash = {
        :destroy_products => deletable,
        :sync_products => syncable,
        :update_sync_plans => editable
      }
      hash
    end

    api :PUT, "/products/bulk/destroy", "Destroy one or more products"
    param :ids, Array, :desc => "List of product ids", :required => true
    def destroy_products
      display_messages = []

      @products.each{ |product| product.destroy }
      display_messages << _("Successfully removed %s product(s)") % @products.length
      respond_for_show :template => 'bulk_action', :resource => { 'displayMessages' => display_messages }
    end

    api :PUT, "/products/bulk/sync", "Sync one or more products"
    param :ids, Array, :desc => "List of product ids", :required => true
    def sync_products
      display_messages = []

      @products.each{ |product| product.sync }
      display_messages << _("Successfully started sync for %s product(s), you are free to leave this page.") % @products.length
      respond_for_show :template => 'bulk_action', :resource => { 'displayMessages' => display_messages }
    end

    api :PUT, "/products/bulk/sync_plan", "Sync one or more products"
    param :ids, Array, :desc => "List of product ids", :required => true
    param :plan_id, :number, :desc => "Sync plan identifier to attach", :required => true
    def update_sync_plans
      display_messages = []

      @products.each do |product|
        product.sync_plan_id = params[:plan_id]
        product.save!
      end

      display_messages << _("Successfully changed sync plan for %s product(s)") % @products.length
      respond_for_show :template => 'bulk_action', :resource => { 'displayMessages' => display_messages }
    end

    private

    def find_products
      params.require(:ids)
      @products = params[:ids].map { |id| Product.find_by_cp_id!(id) }
    end

  end
end
