module Katello
  module Glue::Candlepin::Owner
    def self.included(base)
      base.send :include, LazyAccessor
      base.send :include, InstanceMethods

      base.class_eval do
        validates :label,
            :presence => true,
            :format => { :with => /\A[\w-]*\z/ }

        lazy_accessor :service_levels, :initializer => lambda { |_s| Resources::Candlepin::Owner.service_levels(label) }
        lazy_accessor :system_purposes, :initializer => lambda { |_s| Resources::Candlepin::Owner.system_purpose(label) }
        lazy_accessor :debug_cert, :initializer => lambda { |_s| load_debug_cert }
      end
    end

    module InstanceMethods
      def owner_details
        @owner_details ||= Resources::Candlepin::Owner.find self.label
        @owner_details['virt_who'] ||= self.subscriptions.using_virt_who.any?

        @owner_details
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

      def simple_content_access?
        content_access_mode == "org_environment"
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
