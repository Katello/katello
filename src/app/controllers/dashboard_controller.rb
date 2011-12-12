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

class DashboardController < ApplicationController

  skip_before_filter :authorize,:require_org

  before_filter :update_preferences_quantity , :except => [:index, :section_id]
  #before_filter :update_preferences_age , :except => [:index, :section_id]


  def index
  end

  def section_id
    'dashboard'
  end


  def sync
    render :partial=>"sync", :locals=>{:quantity=> quantity}
  end

  def errata
    render :partial=>"errata", :locals=>{:quantity=> quantity}
  end

  def promotions
    render :partial=>"promotions", :locals=>{:quantity=>quantity}
  end

  def systems
    render :partial=>"systems", :locals=>{:quantity=>quantity}
  end

  def subscriptions
    render :partial=>"subscriptions", :locals=>{:quantity=>quantity}
  end

  def notices
    render :partial=>"notices", :locals=>{:quantity=>quantity}
  end

  private

  def update_preferences_quantity
    action = params[:action]
    num_of_items = params[:quantity].to_i
    if num_of_items && num_of_items > 0 && quantity != num_of_items
      current_user.preferences = HashWithIndifferentAccess.new  unless current_user.preferences
      current_user.preferences[:dashboard] = {} unless current_user.preferences.has_key? :dashboard
      current_user.preferences[:dashboard][action] = {:page_size => num_of_items}
      current_user.save!
    end
  end

  helper_method :quantity
  def quantity
    current_user.preferences[:dashboard][params[:action]][:page_size] rescue 5
  end
end
