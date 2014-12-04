#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

# rubocop:disable Style/AccessorMethodName
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
        pools = []
        key_pools.each do |key_pool|
          key_pool[:pool][:amount] = (key_pool[:quantity] ? key_pool[:quantity] : 0)
          pools << key_pool[:pool]
        end
        pools
      end

      def subscribe(pool_id, quantity = 1)
        Resources::Candlepin::ActivationKey.add_pools self.cp_id, pool_id, quantity
      end

      def unsubscribe(pool_id)
        Resources::Candlepin::ActivationKey.remove_pools self.cp_id, pool_id
      end

      def set_content_override(content_label, name, value = nil)
        Resources::Candlepin::ActivationKey.update_content_override(self.cp_id, content_label, name, value)
      end

      def content_overrides
        Resources::Candlepin::ActivationKey.content_overrides(self.cp_id)
      end
    end
  end
end
