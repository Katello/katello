
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
class ProvidersController < Katello::ApplicationController

  before_filter :find_rh_provider, :only => [:redhat_provider, :redhat_provider_tab]
  before_filter :search_filter, :only => [:auto_complete_search]

  respond_to :html, :js

  def section_id
    'contents'
  end

  def redhat_provider
    render :template => "katello/providers/redhat/show"
  end

  def redhat_provider_tab
    #preload orphaned product information, as it is very slow per product
    subscription_product_ids = []

    subscriptions = Resources::Candlepin::Subscription.get_for_owner(current_organization.label)
    subscriptions.each do |sub|
      subscription_product_ids << sub['product']['id'] if sub['product']['id']
      subscription_product_ids += sub['providedProducts'].map{|p| p['id']} if sub['providedProducts']
      subscription_product_ids += sub['derivedProvidedProducts'].map{|p| p['id']} if sub['derivedProvidedProducts']
    end

    orphaned_product_ids = current_organization.redhat_provider.products.engineering.
        where("cp_id not in (?)", subscription_product_ids).pluck(:id)

    render :partial => "katello/providers/redhat/tab",
           :locals => { :tab_id => params[:tab], :orphaned_product_ids => orphaned_product_ids }
  end

  def find_rh_provider
    @provider = current_organization.redhat_provider
  end

  def controller_display_name
    return 'provider'
  end

  def search_filter
    @filter = {:organization_id => current_organization}
  end

  def title
    _('Repositories')
  end

end
end
