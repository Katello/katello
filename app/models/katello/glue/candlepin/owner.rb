module Katello
  module Glue::Candlepin::Owner
    def self.included(base)
      base.send :include, LazyAccessor
      base.send :include, InstanceMethods

      base.class_eval do
        validates :label,
            :presence => true,
            :format => { :with => /\A[\w-]*\z/ }

        lazy_accessor :events, :initializer => lambda { |_s| Resources::Candlepin::Owner.events(label) }
        lazy_accessor :service_levels, :initializer => lambda { |_s| Resources::Candlepin::Owner.service_levels(label) }
        lazy_accessor :debug_cert, :initializer => lambda { |_s| load_debug_cert }
      end
    end

    module InstanceMethods
      def owner_info
        Glue::Candlepin::OwnerInfo.new(self)
      end

      def owner_details
        details = Resources::Candlepin::Owner.find self.label
        details['virt_who'] = self.subscriptions.using_virt_who.any?
        details
      end

      def service_level
        self.owner_details['defaultServiceLevel']
      end

      def service_level=(level)
        Resources::Candlepin::Owner.update(self.label, :defaultServiceLevel => level)
      end

      def content_access_mode
        self.owner_details['contentAccessMode']
      end

      def enabled_product_content_for(repositories)
        return [] if repositories.blank?
        content_ids = repositories.pluck(:content_id)

        filtered_product_content do |pc|
          content_ids.include?(pc.content.id) && pc.product.enabled?
        end
      end

      def enabled_product_content
        filtered_product_content do |pc|
          pc.product.enabled? && pc.product.redhat?
        end
      end

      def filtered_product_content
        cp_products = Katello::Resources::Candlepin::Product.all(self.label, ['id', 'productContent.enabled', 'productContent.content.name', 'productContent.content.id',
                                                                              'productContent.content.type', 'productContent.content.contentUrl', 'productContent.content.label'])
        to_return = []

        cp_products.each do |product_hash|
          product = ::Katello::Product.find_by(:organization_id => self.id, :cp_id => product_hash['id'])
          if product
            product_hash['productContent'].each do |pc_hash|
              pc = Katello::Candlepin::ProductContent.new(pc_hash, product.id)
              to_return << pc if !block_given? || yield(pc)
            end
          end
        end
        to_return.sort_by { |pc| pc.content.name.downcase }
      end

      def pools(consumer_uuid = nil)
        if consumer_uuid
          Resources::Candlepin::Owner.pools self.label, :consumer => consumer_uuid
        else
          Resources::Candlepin::Owner.pools self.label
        end
      end

      def generate_debug_cert
        Resources::Candlepin::Owner.generate_ueber_cert(label)
      end

      def load_debug_cert
        return Resources::Candlepin::Owner.get_ueber_cert(label)
      rescue RestClient::ResourceNotFound
        return generate_debug_cert
      end

      def imports
        Resources::Candlepin::Owner.imports(self.label)
      end
    end
  end
end
