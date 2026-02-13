# rubocop:disable Naming/AccessorMethodName
module Katello
  module Glue::Candlepin::ActivationKey
    def self.included(base)
      base.send :include, LazyAccessor
      base.send :include, InstanceMethods

      base.class_eval do
        lazy_accessor :service_level,
                      :initializer => (lambda do |_s|
                                         Resources::Candlepin::ActivationKey.get(cp_id)[0][:serviceLevel] if cp_id
                                       end)
        lazy_accessor :cp_name,
                      :initializer => (lambda do |_s|
                                         Resources::Candlepin::ActivationKey.get(cp_id)[0][:name] if cp_id
                                       end)
      end
    end

    module InstanceMethods
      def set_content_overrides(overrides)
        Resources::Candlepin::ActivationKey.update_content_overrides(self.cp_id, overrides.map(&:to_entitlement_hash))
      end

      def content_overrides
        Resources::Candlepin::ActivationKey.content_overrides(self.cp_id).map do |overrides|
          ::Katello::ContentOverride.from_entitlement_hash(overrides)
        end
      end
    end
  end
end
