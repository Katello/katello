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

    before_filter :find_products

    api :PUT, "/products/bulk/destroy", "Destroy one or more products"
    param :ids, Array, :desc => "List of product ids", :required => true
    def destroy_products
      deletable_products = @products.deletable
      deletable_products.each(&:destroy)

      messages = format_bulk_action_messages(
        :success    => _("Successfully removed %s product(s)"),
        :error      => _("You were not allowed to delete %s"),
        :models     => @products,
        :authorized => deletable_products
      )

      respond_for_show :template => 'bulk_action', :resource_name => 'common',
                       :resource => { 'displayMessages' => messages }
    end

    api :PUT, "/products/bulk/sync", "Sync one or more products"
    param :ids, Array, :desc => "List of product ids", :required => true
    def sync_products
      syncable_products = @products.syncable
      syncable_products.each(&:sync)

      messages = format_bulk_action_messages(
        :success    => _("Successfully started sync for %s product(s), you are free to leave this page."),
        :error      => _("You were not allowed to sync %s"),
        :models     => @products,
        :authorized => syncable_products
      )

      respond_for_show :template => 'bulk_action', :resource_name => 'common',
                       :resource => { 'displayMessages' => messages }
    end

    api :PUT, "/products/bulk/sync_plan", "Sync one or more products"
    param :ids, Array, :desc => "List of product ids", :required => true
    param :plan_id, :number, :desc => "Sync plan identifier to attach", :required => true
    def update_sync_plans
      editable_products = @products.editable
      editable_products.each do |product|
        product.sync_plan_id = params[:plan_id]
        product.save!
      end

      messages = format_bulk_action_messages(
        :success    => _("Successfully changed sync plan for %s product(s)"),
        :error      => _("You were not allowed to change sync plan for %s"),
        :models     => @products,
        :authorized => editable_products
      )

      respond_for_show :template => 'bulk_action', :resource_name => 'common',
                       :resource => { 'displayMessages' => messages }
    end

    private

    def find_products
      params.require(:ids)
      @products = Product.where(:cp_id => params[:ids])
    end

  end
end
