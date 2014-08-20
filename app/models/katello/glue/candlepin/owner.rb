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

module Katello
module Glue::Candlepin::Owner

  def self.included(base)
    base.send :include, LazyAccessor
    base.send :include, InstanceMethods

    base.class_eval do
      validates :label,
          :presence => true,
          :format => { :with => /^[\w-]*$/ }

      lazy_accessor :events, :initializer => lambda {|s| Resources::Candlepin::Owner.events(label) }
      lazy_accessor :service_levels, :initializer => lambda {|s| Resources::Candlepin::Owner.service_levels(label) }
      lazy_accessor :debug_cert, :initializer => lambda {|s| load_debug_cert}
    end
  end

  module InstanceMethods

    def serializable_hash(options = {})
      hash = super(options)
      hash = hash.merge(:service_levels => self.service_levels)
      hash = hash.merge(:service_level => self.service_level)
      hash
    end

    def owner_info
      Glue::Candlepin::OwnerInfo.new(self)
    end

    def owner_details
      Resources::Candlepin::Owner.find self.label
    end

    def service_level
      self.owner_details['defaultServiceLevel']
    end

    def service_level=(level)
      Resources::Candlepin::Owner.update(self.label, {:defaultServiceLevel => level})
    end

    def pools(consumer_uuid = nil)
      if consumer_uuid
        pools = Resources::Candlepin::Owner.pools self.label, { :consumer => consumer_uuid }
      else
        pools = Resources::Candlepin::Owner.pools self.label
      end
      pools.collect { |p| Katello::Pool.new p }
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
