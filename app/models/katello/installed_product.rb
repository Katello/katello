module Katello
  class InstalledProduct < Katello::Model
    has_many :subscription_facet_installed_products, :class_name => "Katello::SubscriptionFacetInstalledProduct", :dependent => :destroy, :inverse_of => :installed_product
    has_many :subscription_facets, :through => :subscription_facet_installed_products, :class_name => "Katello::Host::SubscriptionFacet"

    alias_attribute :product_id, :cp_product_id
    alias_attribute :product_name, :name

    def self.find_or_create_from_consumer(consumer_attributes)
      attributes = {
        :arch => consumer_attributes['arch'],
        :version => consumer_attributes['version'],
        :name => consumer_attributes['productName'],
        :cp_product_id => consumer_attributes['productId'],
      }
      Katello::Util::Support.active_record_retry do
        unless self.where(attributes).exists?
          self.create!(attributes)
        end
      end
      self.where(attributes).first
    end

    def consumer_attributes
      {
        :arch => arch,
        :version => version,
        :productName => name,
        :productId => cp_product_id,
      }
    end
  end
end
