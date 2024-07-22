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
      def get_pools
        Resources::Candlepin::ActivationKey.pools(self.organization.label)
      end

      def get_keys
        Resources::Candlepin::ActivationKey.get
      end

      def get_key_pools
        key_pools = Resources::Candlepin::ActivationKey.get(self.cp_id)[0][:pools]
        key_pools.map do |key_pool|
          {
            :amount => (key_pool[:quantity] || 0),
            :id => key_pool[:poolId],
          }.with_indifferent_access
        end
      end

      def import_pools
        key_pools = self.get_key_pools
        pools = Katello::Pool.where(:cp_id => key_pools.map { |pool| pool['id'] })
        associations = Katello::PoolActivationKey.where(:activation_key_id => self.id)
        associations.map { |assoc| assoc.destroy! if pools.map(&:id).exclude?(assoc.pool_id) }
        pools.each do |pool|
          Katello::PoolActivationKey.where(:pool_id => pool.id, :activation_key_id => self.id).first_or_create
        end
      end

      def subscribe(pool_id, quantity = 1)
        pool = Katello::Pool.with_identifier(pool_id)
        subscription = pool.subscription
        add_custom_product(subscription.cp_id) unless subscription.redhat?
        Resources::Candlepin::ActivationKey.add_pools self.cp_id, pool.cp_id, quantity
        self.import_pools
      end

      def unsubscribe(pool_id)
        fail _("Subscription id is nil.") unless pool_id
        pool = Katello::Pool.with_identifier(pool_id)
        subscription = pool.subscription
        remove_custom_product(subscription.cp_id) unless subscription.redhat?
        Resources::Candlepin::ActivationKey.remove_pools self.cp_id, pool.cp_id
        self.import_pools
      end

      def set_content_overrides(overrides)
        Resources::Candlepin::ActivationKey.update_content_overrides(self.cp_id, overrides.map(&:to_entitlement_hash))
      end

      def content_overrides
        Resources::Candlepin::ActivationKey.content_overrides(self.cp_id).map do |overrides|
          ::Katello::ContentOverride.from_entitlement_hash(overrides)
        end
      end

      private

      def add_custom_product(product_id)
        Resources::Candlepin::ActivationKey.add_product self.cp_id, product_id
      end

      def remove_custom_product(product_id)
        Resources::Candlepin::ActivationKey.remove_product self.cp_id, product_id
      end
    end
  end
end
