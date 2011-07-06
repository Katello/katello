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

class SyncSchedulesController < ApplicationController

  def section_id
    'contents'
  end

  def index

    @organization = current_organization
    rproducts = @organization.locker.products.reject { |p| p.productContent.empty? }
    @products = rproducts.sort { |p1,p2| p1.name <=> p2.name }

    @plans = SyncPlan.where(:organization_id => current_organization.id)

    for p in @products

    end

    @products_options = { :title => _('Select Products to schedule'),
                 :col => ['name', 'plan_name'],
                 :create => _('Plan'),
                 :name => _('product'),
                 :enable_create => false}

    @plans_options = { :title => _('Select Plans to apply to selected Products'),
                 :col => ['name', 'interval'],
                 :create => _('Plan'),
                 :name => _('plan'),
                :hover_text_cb => :hover_format,
                 :enable_create => false,
                :single_select => true}


    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def apply
    data = JSON.parse(params[:data]).with_indifferent_access
    selected_plans = data[:plans].collect{ |i| i.to_i}
    selected_products = data[:products].collect{ |i| i.to_i}
    plans = SyncPlan.where(:id => selected_plans)
    products = Product.where(:id => selected_products)

    products.each do |prod|
      unless plans.empty?
        plans.each do |plan|
          prod.sync_plan = plan
        end
      else
          prod.sync_plan = nil
      end
      prod.save!
    end
    notice N_("Sync Plans applied successfully.")
    redirect_to(:controller => :sync_schedules, :action =>:index)
  end

end
