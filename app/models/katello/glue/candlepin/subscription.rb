module Katello
  module Glue::Candlepin::Subscription
    def self.included(base)
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def candlepin_data(cp_id)
        Katello::Resources::Candlepin::Subscription.get(cp_id)
      end

      def get_for_owner(organization = self.organization.label)
        Katello::Resources::Candlepin::Subscription.get_for_owner(organization)
      end
    end

    module InstanceMethods
      def backend_data
        self.class.candlepin_data(self.cp_id)
      end

      def query_products
        self.backend_data["providedProducts"]
      end

      def import_data
        subscription_attributes = {}
        subscription_json = self.backend_data

        subscription_json["product"]["attributes"].map { |attr| subscription_attributes[attr["name"].to_sym] = attr["value"] }

        subscription_attributes[:name] = subscription_json["product"]["name"]
        subscription_attributes[:product_id] = subscription_json["product"]["id"]
        subscription_attributes[:instance_multiplier] = subscription_json["product"]["multiplier"]
        subscription_attributes[:stacking_id] = subscription_json["stackId"]
        organization = Organization.find_by(:label => subscription_json["owner"]["key"]) if subscription_json["owner"]
        subscription_attributes[:organization_id] = organization.id if organization

        exceptions = subscription_attributes.keys.map(&:to_sym) - self.attribute_names.map(&:to_sym)
        self.update_attributes!(subscription_attributes.except!(*exceptions))
        self.create_product_associations
      end

      def create_product_associations
        products = self.query_products
        cp_product_ids = products.map { |product| product["id"] }
        cp_product_ids << self.product_id if self.product_id
        cp_product_ids.each do |cp_id|
          product = ::Katello::Product.where(:cp_id => cp_id)
          if product.any?
            ::Katello::SubscriptionProduct.where(:subscription_id => self.id, :product_id => product.first.id).first_or_create
          end
        end
      end
    end
  end
end
