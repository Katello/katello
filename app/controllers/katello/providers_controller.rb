module Katello
  class ProvidersController < Katello::ApplicationController
    helper Rails.application.routes.url_helpers
    helper ReactjsHelper
    before_action :find_rh_provider, :only => [:redhat_provider, :redhat_provider_tab]
    before_action :search_filter, :only => [:auto_complete_search]

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
      included_list = %w(product.id providedProducts.id derivedProvidedProducts.id)
      subscriptions = Resources::Candlepin::Subscription.get_for_owner(current_organization.label, included_list)
      subscriptions.each do |sub|
        subscription_product_ids << sub['product']['id'] if sub['product']['id']
        subscription_product_ids += sub['providedProducts'].map { |p| p['id'] } if sub['providedProducts']
        subscription_product_ids += sub['derivedProvidedProducts'].map { |p| p['id'] } if sub['derivedProvidedProducts']
      end

      orphaned_products = current_organization.redhat_provider.products
      orphaned_products = orphaned_products.where("cp_id not in (?)", subscription_product_ids) if subscription_product_ids.any?
      orphaned_product_ids = orphaned_products.pluck(:id)

      render :partial => "katello/providers/redhat/tab",
             :locals => { :tab_id => params[:tab], :orphaned_product_ids => orphaned_product_ids }
    end

    def find_rh_provider
      @provider = current_organization.redhat_provider
    end

    def controller_display_name
      'provider'
    end

    def search_filter
      @filter = {:organization_id => current_organization}
    end

    def title
      _('Repositories')
    end
  end
end
