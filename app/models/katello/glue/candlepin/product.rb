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

    def self.validate_name(name)
      name.gsub(/[^a-z0-9\-_ ]/i, "")
    end

    def self.import_from_cp(attrs = nil, &block)
      product_content_attrs = attrs.delete(:productContent) || []
      import_logger = attrs[:import_logger]

      attrs = attrs.merge('name' => validate_name(attrs['name']), 'label' => Util::Model.labelize(attrs['name']))

      product = Product.new(attrs, &block)
      product.save!
      import_product_content(product, product_content_attrs)
    rescue => e
      [Rails.logger, import_logger].each do |logger|
        logger.error "Failed to create product #{attrs['name']}: #{e}" if logger
      end
      raise e
    end

    def self.import_product_content(product, content_attrs)
      content_attrs.each do |attrs|
        params = attrs.with_indifferent_access
        pc = params[:content]

        content_attrs = {
          cp_content_id: pc[:id],
          name: pc[:name],
          label: pc[:label],
          content_type: pc[:type],
          vendor: pc[:vendor],
          gpg_url: pc[:gpgUrl],
          content_url: pc[:contentUrl]
        }

        # current product has this content - update it
        # otherwise create a reference to existing content OR new content altogether
        if (existing = product.product_content_by_id(pc[:id]))
          existing.content.update_attributes!(content_attrs)
          existing.update_attributes(enabled: params['enabled'])
        else
          content = ::Katello::Content.find_by_cp_content_id(pc[:id])
          content ||= ::Katello::Content.create!(content_attrs)

          ::Katello::ProductContent.create!(enabled: params[:enabled],
                                            product_id: product.id,
                                            content: content)
        end
      end
    end

    module InstanceMethods
      def initialize(attribs = nil)
        unless attribs.nil?
          attributes_key = attribs.key?(:attributes) ? :attributes : 'attributes'
          if attribs.key?(attributes_key)
            attribs[:attrs] = attribs[attributes_key]
            attribs.delete(attributes_key)
          end

          # ugh. hack-ish. otherwise we have to modify code every time things change on cp side
          attribs = attribs.reject do |k, _v|
            !self.class.column_defaults.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
          end
        end

        super
      end

      def orphaned?
        self.provider.redhat_provider? && self.certificate.nil?
      end

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
        sub = nil
        ::Katello::Util::Support.active_record_retry do
          sub = ::Katello::Subscription.where(:cp_id => self.cp_id, :organization_id => self.organization.id).first_or_create
        end
        sub.import_data
        pools = ::Katello::Resources::Candlepin::Product.pools(self.organization.label, self.cp_id)
        pools.each { |pool_json| ::Katello::Pool.import_pool(pool_json['id']) }
      end
    end
  end
end
