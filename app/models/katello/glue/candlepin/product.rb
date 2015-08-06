module Katello
  module Glue::Candlepin::Product
    def self.included(base)
      base.send :include, LazyAccessor
      base.send :include, InstanceMethods

      base.class_eval do
        lazy_accessor :productContent, :multiplier, :href, :attrs,
          :initializer => lambda { |_s| convert_from_cp_fields(Resources::Candlepin::Product.get(cp_id)[0]) }
        # Entitlement Certificate for this product
        lazy_accessor :certificate,
          :initializer => lambda { |_s| Resources::Candlepin::Product.certificate(cp_id, self.organization.label) },
          :unless => lambda { |_s| cp_id.nil? }
        # Entitlement Key for this product
        lazy_accessor :key, :initializer => lambda { |_s| Resources::Candlepin::Product.key(cp_id, self.organization.label) }, :unless => lambda { |_s| cp_id.nil? }

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
      import_logger        = attrs[:import_logger]

      attrs = attrs.merge('name' => validate_name(attrs['name']), 'label' => Util::Model.labelize(attrs['name']))

      product = Product.new(attrs, &block)
      product.orchestration_for = :import_from_cp_ar_setup
      product.save!
      product.productContent_will_change!
      product.productContent = product.build_product_content(product_content_attrs)
      product.orchestration_for = :import_from_cp
      product.save!

    rescue => e
      [Rails.logger, import_logger].each do |logger|
        logger.error "Failed to create product #{attrs['name']}: #{e}" if logger
      end
      raise e
    end

    def self.import_marketing_from_cp(attrs, engineering_product_ids, &block)
      attrs = attrs.merge('name' => validate_name(attrs['name']), 'label' => Util::Model.labelize(attrs['name']))

      product = MarketingProduct.new(attrs, &block)
      product.orchestration_for = :import_from_cp_ar_setup
      product.save!
      engineering_product_ids.each do |engineering_product_id|
        product.marketing_engineering_products.create(:engineering_product_id => engineering_product_id)
      end
      product
    rescue => e
      Rails.logger.error "Failed to create product #{attrs['name']}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    module InstanceMethods
      def initialize(attribs = nil, options = {})
        unless attribs.nil?
          attributes_key = attribs.key?(:attributes) ? :attributes : 'attributes'
          if attribs.key?(attributes_key)
            attribs[:attrs] = attribs[attributes_key]
            attribs.delete(attributes_key)
          end

          @productContent = [] unless attribs.key?(:productContent)

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

      def build_product_content(attrs)
        @productContent = attrs.collect { |pc| Candlepin::ProductContent.new pc }
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
        ar_safe_json[:productContent] = ar_safe_json[:productContent].collect { |pc| Candlepin::ProductContent.new(pc, self.id) }
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
        Resources::Candlepin::Product.add_content self.cp_id, content.content.id, true
        self.productContent << content
      end

      def remove_content_by_id(content_id)
        Resources::Candlepin::Product.remove_content cp_id, content_id
      end

      def product_content_by_id(content_id)
        self.productContent.find { |pc| pc.content.id == content_id }
      end

      def product_content_by_name(content_name)
        self.productContent.find { |pc| pc.content.name == content_name }
      end

      protected

      def added_content
        old_content_ids = productContent_change[0].nil? ? [] : productContent_change[0].map { |pc| pc.content.label }
        new_content_ids = productContent_change[1].map { |pc| pc.content.label }

        added_content_ids = new_content_ids - old_content_ids

        added_content = productContent_change[1].select { |pc| added_content_ids.include?(pc.content.label) }
        added_content
      end

      def deleted_content
        old_content_ids = productContent_change[0].nil? ? [] : productContent_change[0].map { |pc| pc.content.label }
        new_content_ids = productContent_change[1].map { |pc| pc.content.label }

        deleted_content_ids = old_content_ids - new_content_ids

        deleted_content = productContent_change[0].select { |pc| deleted_content_ids.include?(pc.content.label) }
        deleted_content
      end
    end
  end
end
