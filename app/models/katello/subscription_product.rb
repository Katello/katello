module Katello
  class SubscriptionProduct < Katello::Model
    belongs_to :product, :inverse_of => :subscription_products, :class_name => 'Katello::Product'
    belongs_to :subscription, :inverse_of => :subscription_products, :class_name => 'Katello::Subscription'
  end
end
