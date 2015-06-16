module Katello
  class DashboardController < Katello::ApplicationController
    def index
    end

    def section_id
      'dashboard'
    end

    def title
      _('Welcome')
    end

    def update
      render :nothing => true
    end

    def sync
      render :partial => "sync", :locals => {:quantity => quantity}
    end

    def errata
      # retrieve the list of repos that are readable by the user,
      # but since a system cannot be registered to Library,
      # skip repos in Library
      systems = System.in_organization(current_organization).readable
      errata = Erratum.applicable_to_systems(systems).order('updated desc').limit(quantity)

      render :partial => "errata", :locals => { :quantity => quantity,
                                                :errata => errata }
    end

    def content_views
      render :partial => "content_views", :locals => {:quantity => quantity}
    end

    def promotions
      render :partial => "promotions", :locals => {:quantity => quantity}
    end

    def host_collections
      render :partial => "host_collections", :locals => {:quantity => quantity}
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

    private

    helper_method :quantity
    def quantity
      Setting.entries_per_page || 5
    end
  end
end
