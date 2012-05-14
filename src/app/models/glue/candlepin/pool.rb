#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require_dependency 'resources/candlepin'

module Glue::Candlepin::Pool

  def self.included(base)
    base.send :include, LazyAccessor
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods

    base.class_eval do
      lazy_accessor :productName, :productId, :startDate, :endDate, :consumed, :quantity, :attrs, :owner,
        :initializer => lambda {
          json = Candlepin::Pool.find(cp_id)
          # symbol "attributes" is reserved by Rails and cannot be used
          json['attrs'] = json['attributes']
          json
        }

      alias_method :poolName, :productName
    end
  end

  module ClassMethods
    def find_by_organization_and_id(organization, pool_id)
      pool = KTPool.find_by_cp_id(pool_id) || KTPool.new(Candlepin::Pool.find(pool_id))
      if pool.organization == organization
        return pool
      end
    end
  end

  module InstanceMethods

    def initialize(attrs = nil)
      if not attrs.nil? and attrs.member? 'id'
        # initializing from candlepin json
        @productName = attrs["productName"]
        @startDate = attrs["startDate"]
        @endDate = attrs["endDate"]
        @consumed = attrs["consumed"]
        @quantity = attrs["quantity"]
        @attrs = attrs["attributes"]
        @owner = attrs["owner"]
        @productId = attrs["productId"]
        super(:cp_id => attrs['id'])
      else
        super
      end
    end

    def startDate_as_datetime
      DateTime.parse(startDate)
    end

    def endDate_as_datetime
      DateTime.parse(endDate)
    end

    def organization
      Organization.find_by_name(owner["key"])
    end

  end
end
