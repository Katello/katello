module Katello
  class Subscription < Katello::Model
    include Glue::Candlepin::CandlepinObject
    include Glue::Candlepin::Subscription
    include Katello::Authorization::Subscription
    has_many :products, :through => :subscription_products, :class_name => "Katello::Product"
    has_many :subscription_products, :class_name => "Katello::SubscriptionProduct", :dependent => :destroy, :inverse_of => :subscription

    has_many :pools, :class_name => "Katello::Pool", :inverse_of => :subscription, :dependent => :destroy

    belongs_to :organization, :class_name => "Organization", :inverse_of => :subscriptions

    scope :in_organization, ->(org) { where(:organization => org) }

    def redhat?
      self.products.any? { |product| product.redhat? }
    end

    def active?
      pools.any?(&:active?)
    end

    def expiring_soon?
      pools.any?(&:expiring_soon?)
    end

    def recently_expired?
      pools.any?(&:recently_expired?)
    end
  end
end
