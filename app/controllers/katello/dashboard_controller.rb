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
class DashboardController < Katello::ApplicationController

  helper ErrataHelper

  skip_before_filter :authorize, :require_org

  before_filter :update_preferences_quantity , :except => [:index, :section_id]
  #before_filter :update_preferences_age , :except => [:index, :section_id]

  def index
  end

  def section_id
    'dashboard'
  end

  def title
    _('Welcome')
  end

  def update
    if params[:columns]
      columns = params[:columns].map { |key, column| column }
      update_user_preference(:layout, columns)
    end
    render :nothing => true
  end

  def sync
    render :partial => "sync", :locals => {:quantity => quantity}
  end

  def errata
    # retrieve the list of repos that are readable by the user,
    # but since a system cannot be registered to Library,
    # skip repos in Library
    system_uuids = System.readable(current_organization).pluck(:uuid)
    errata = Errata.applicable_for_consumers(system_uuids)

    errata = errata.sort_by{|e| (e.applicable_consumers || []).length }.reverse[0...quantity]

    render :partial => "errata", :locals => { :quantity => quantity,
                                              :errata => errata }
  end

  def content_views
    render :partial => "content_views", :locals => {:quantity => quantity}
  end

  def promotions
    render :partial => "promotions", :locals => {:quantity => quantity}
  end

  def systems
    render :partial => "systems", :locals => {:quantity => quantity}
  end

  def system_groups
    render :partial => "system_groups", :locals => {:quantity => quantity}
  end

  def subscriptions
    render :partial => "subscriptions", :locals => {:quantity => quantity}
  end

  def subscriptions_totals
    subscriptions = current_organization.redhat_provider.index_subscriptions

    render :partial => "subscriptions_totals", :locals => {
      :quantity                             => nil,
      :total_active_subscriptions           => Katello::Pool.active(subscriptions).count,
      :total_expiring_subscriptions         => Katello::Pool.expiring_soon(subscriptions).count,
      :total_recently_expired_subscriptions => Katello::Pool.recently_expired(subscriptions).count
    }
  end

  def utilization
    products = Katello::Product.in_org(current_organization).select { |product| product.total_subscriptions.present? }
    render :partial => "utilization", :locals => {
      :quantity => products.count,
      :products => products
    }
  end

  def notices
    render :partial => "notices", :locals => {:quantity => quantity}
  end

  private

  def update_preferences_quantity
    action = params[:action]
    num_of_items = params[:quantity].to_i
    if num_of_items && num_of_items > 0 && quantity != num_of_items
      update_user_preference(action, {:page_size => num_of_items})
      current_user.save!
    end
  end

  def update_user_preference(key, value)
    current_user.preferences = HashWithIndifferentAccess.new  unless current_user.preferences
    current_user.preferences[:dashboard] = {} unless current_user.preferences.key? :dashboard
    current_user.preferences[:dashboard][key] = value
    current_user.save!
  end

  helper_method :quantity
  def quantity
    current_user.preferences[:dashboard][params[:action]][:page_size] rescue 5
  end
end
end
