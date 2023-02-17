module Katello
  module Glue::Candlepin::Subscription
    def self.included(base)
      base.send :include, LazyAccessor
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods

      base.class_eval do
        lazy_accessor :backend_data, :initializer => lambda { |_s| self.class.candlepin_data(self.organization.label, self.cp_id) }
      end
    end

    module ClassMethods
      def candlepin_data(org, cp_id)
        Katello::Resources::Candlepin::Product.get(org, cp_id)[0]
      end

      def get_for_owner(organization)
        Katello::Resources::Candlepin::Product.all(organization).select do |product|
          #this product's id is non-numeric (marketing product), or its a custom product
          !Glue::Candlepin::Product.engineering_product_id?(product['id']) || Katello::Product.find_by(:cp_id => product['id']).try(:custom?)
        end
      end

      def import_candlepin_records(cp_subs, org)
        cp_subs = cp_subs.reject { |cp_subscription| ::Katello::Glue::Provider.orphaned_custom_product?(cp_subscription['productId'], org) }
        super(cp_subs, org)
      end
    end

    module InstanceMethods
      def import_data
        subscription_attributes = {}
        product_json = self.backend_data

        product_json["attributes"].each { |attr| subscription_attributes[attr["name"].to_sym] = attr["value"] }

        subscription_attributes[:name] = product_json["name"]
        subscription_attributes[:instance_multiplier] = product_json["multiplier"]

        exceptions = subscription_attributes.keys.map(&:to_sym) - self.attribute_names.map(&:to_sym)
        self.update!(subscription_attributes.except!(*exceptions))
      end
    end
  end
end
