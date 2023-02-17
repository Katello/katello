module Katello
  module Glue::Candlepin::Product
    PRODUCT_ATTRS = %w(name attributes.name attributes.value).freeze

    def self.included(base)
      base.send :include, LazyAccessor
      base.send :include, InstanceMethods

      base.class_eval do
        lazy_accessor :multiplier, :href, :attrs,
          :initializer => (lambda do |_s|
            convert_from_cp_fields(
              Resources::Candlepin::Product.get(self.organization.label, cp_id, PRODUCT_ATTRS)[0]
            )
          end)

        lazy_accessor :product_certificate,
          :initializer => lambda { |_s| Resources::Candlepin::Product.product_certificate(cp_id, self.organization.label) },
          :unless => lambda { |_s| cp_id.nil? }
        # Entitlement Certificate for this product
        lazy_accessor :certificate, :initializer => lambda { |_s| product_certificate['cert'] if product_certificate }
        # Entitlement Key for this product
        lazy_accessor :key, :initializer => lambda { |_s| product_certificate['key'] if product_certificate }

        # we must store custom logger object during product importing so we can log status
        # from various places like callbacks
        attr_accessor :import_logger
      end
    end

    def self.engineering_product_id?(id)
      id.match(/^\d+$/) #engineering products are numeric
    end

    def self.import_redhat_product_from_cp(attrs, organization)
      import_logger = attrs[:import_logger]

      product_attrs = {'name' => attrs['name'],
                       'cp_id' => attrs['id'],
                       'label' => Util::Model.labelize(attrs['name']),
                       'multiplier' => attrs['multiplier'],
                       'organization_id' => organization.id,
                       'provider_id' => organization.redhat_provider.id}

      Product.create!(product_attrs)
    rescue => e
      [Rails.logger, import_logger].each do |logger|
        logger&.error "Failed to create product #{attrs['name']}: #{e}"
      end
      raise e
    end

    def self.custom_product_id?(id)
      # Engineering products with 12 digits are custom products (see Katello::Product#unused_product_id)
      # however, previously generated ids are random and can be shorter than 12 digits
      id =~ /^\d{8,12}$/
    end

    module InstanceMethods
      def support_level
        return _attr(:support_level)
      end

      def arch
        attrs.each do |attr|
          if attr[:name] == 'arch'
            return "noarch" if attr[:value] == 'ALL'
            return attr[:value]
          end
        end
        default_arch
      end

      def _attr(key)
        puts "Looking for: #{key}"
        attrs.each do |attr|
          puts "attr: name: #{attr[:name]} value: #{attr[:value]}"
          if attr[:name] == key.to_s
            return attr[:value]
          end
        end
        nil
      end

      def default_arch
        "noarch"
      end

      def convert_from_cp_fields(cp_json)
        ar_safe_json = cp_json.key?(:attributes) ? cp_json.merge(:attrs => cp_json.delete(:attributes)) : cp_json
        ar_safe_json[:attrs] = remove_hibernate_fields(cp_json[:attrs]) if ar_safe_json.key?(:attrs)
        ar_safe_json[:attrs] ||= []
        ar_safe_json.except('id')
      end

      # Candlepin sends back its internal hibernate fields in the json. However it does not accept them in return
      # when updating (PUT) objects.
      def remove_hibernate_fields(elements)
        return nil unless elements
        elements.collect { |e| e.except(:id, :created, :updated) }
      end

      def add_content(content)
        Resources::Candlepin::Product.add_content(self.organization.label, self.cp_id, content.content.id, true)
        self.productContent << content
      end

      def import_custom_subscription
        fail _("Cannot import a custom subscription from a redhat product.") if self.redhat?
        User.as_anonymous_admin do
          sub = nil
          ::Katello::Util::Support.active_record_retry do
            sub = ::Katello::Subscription.where(:cp_id => self.cp_id, :organization_id => self.organization.id).first_or_create
          end
          unless sub.persisted?
            message = _("Subscription was not persisted - %{error_message}") % {:error_message => sub.errors.full_messages.join("; ")}
            fail HttpErrors::UnprocessableEntity, message
          end
          sub.import_data
          pools = ::Katello::Resources::Candlepin::Product.pools(self.organization.label, self.cp_id)
          pools.each { |pool_json| ::Katello::Pool.import_pool(pool_json['id']) }
        end
      end
    end
  end
end
