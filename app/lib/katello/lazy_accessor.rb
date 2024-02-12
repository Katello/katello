module Katello
  module LazyAccessor
    def self.included(base)
      base.send :include, LazyAccessor::InstanceMethods
      base.send :extend, LazyAccessor::ClassMethods
    end

    module ClassMethods
      attr_accessor :lazy_attributes

      def lazy_attributes_options(attr)
        if @lazy_attributes_options&.key?(attr)
          @lazy_attributes_options.fetch(attr.to_s)
        elsif superclass.respond_to?(:lazy_attributes_options)
          superclass.lazy_attributes_options(attr.to_s)
        else
          fail "lazy attribute #{attr} not defined"
        end
      end

      # @example lazy_accessor :a, :b, :c,
      #   :initializer => lambda { json = Resources::Candlepin::Product.get(cp_id)[0] },
      #   :unless => lambda { cp_id.nil? }
      def lazy_accessor(*args)
        options = args.extract_options!
        @lazy_attributes = [] if @lazy_attributes.nil?
        @lazy_attributes = @lazy_attributes.concat args
        @lazy_attributes_options ||= {}
        fail ArgumentError, "Attribute names must be symbols" if args.any? { |attribute| !attribute.is_a?(Symbol) }
        redefined_attr = args.find { |attribute| instance_methods.include?(attribute.to_s) }
        Rails.logger.warn "Remote attribute '#{redefined_attr}' has already been defined" if redefined_attr

        fail ArgumentError, "Please provide an initializer" if options[:initializer].nil?

        args.each do |symbol|
          options[:in_group] = args.size > 1
          @lazy_attributes_options[symbol.to_s] = options

          send :define_method, "#{symbol.to_s}=" do |val|
            lazy_attribute_set(symbol, val)
          end

          send :define_method, symbol do
            lazy_attribute_get(symbol)
          end
        end
      end
    end

    module InstanceMethods
      def changed_remote_attributes
        @changed_remote_attributes ||= {}
      end

      def changed_remote_attributes=(val)
        @changed_remote_attributes = val
      end

      def save(...)
        if (status = super(...))
          changed_remote_attributes.clear
        end
        status
      end

      def save!(...)
        super(...).tap do
          changed_remote_attributes.clear
        end
      end

      def reload(...)
        super(...).tap do
          changed_remote_attributes.clear
        end
      end

      def lazy_attributes
        attrs = (self.class.superclass.respond_to? :lazy_attributes) ? self.class.superclass.lazy_attributes : []
        attrs += (self.class.lazy_attributes || [])
        attrs.uniq
      end

      private

      def lazy_attribute_set(attr, val)
        instance_variable_set("@#{attr.to_s}", val)
      end

      def lazy_attribute_get(attr)
        attr = attr.to_s

        options = self.class.lazy_attributes_options(attr)

        excepted = options.key?(:unless) ? self.instance_eval(&options[:unless]) : (self.is_a?(ActiveRecord::Base) && self.new_record?)
        if !instance_variable_defined?("@#{attr}") && !excepted
          remote_values = run_initializer(options[:in_group], options[:initializer])
          if options[:in_group]
            prepopulate(remote_values)
          else
            instance_variable_set("@#{attr}", remote_values) if respond_to?("#{attr}=")
          end
        end
        instance_variable_get("@#{attr}")
      end

      def remote_attribute_value(attr)
        return nil if self.is_a?(ActiveRecord::Base) && self.new_record?

        options = self.class.lazy_attributes_options(attr)
        initializer, in_group = options[:initializer], options[:in_group]

        remote_values = run_initializer(in_group, initializer)
        changed_remote_attributes[attr] = in_group ? remote_values["#{attr}"] : remote_values
      end

      def run_initializer(in_group, initializer)
        remote_values = self.instance_eval(&initializer)
        if in_group && !remote_values.is_a?(Hash)
          fail "Expect initializer to return hash if a group of attributes is defined by lazy_accessor"
        end
        remote_values
      end

      def prepopulate(remote_values)
        attrs = self.lazy_attributes
        # if +load_remote_data+ is defined, use it to populate the instance variables
        if self.respond_to?(:load_remote_data)
          load_remote_data(remote_values)
        else
          remote_values.each_pair do |k, v|
            instance_variable_set("@#{k.to_s}", v) if (attrs&.include?(k.to_sym) && respond_to?("#{k.to_s}="))
          end
        end
      end
    end
  end
end
