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

module Glue::Candlepin::Pool

  def self.included(base)
    base.send :include, LazyAccessor
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods

    base.class_eval do
      lazy_accessor :poolDerived, :productName, :consumed, :quantity, :supportLevel, :supportType,
        :startDate, :endDate, :attrs, :owner, :productId, :accountNumber, :contractNumber,
        :sourcePoolId, :hostId, :virtOnly, :virtLimit,
        :arch, :sockets, :description, :productFamily, :variant, :providedProducts,
        :initializer => lambda {
          json = Resources::Candlepin::Pool.find(cp_id)
          # symbol "attributes" is reserved by Rails and cannot be used
          json['attrs'] = json['attributes']
          json
        }
    end
  end

  module ClassMethods
    def find_by_organization_and_id(organization, pool_id)
      pool = Pool.find_by_cp_id(pool_id) || Pool.new(Resources::Candlepin::Pool.find(pool_id))
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
        @startDate = Date.parse(attrs["startDate"])
        @endDate = Date.parse(attrs["endDate"])
        @consumed = attrs["consumed"]
        @quantity = attrs["quantity"]
        @attrs = attrs["attributes"]
        @owner = attrs["owner"]
        @productId = attrs["productId"]
        @cp_id = attrs['id']
        @accountNumber = attrs['accountNumber']
        @contractNumber = attrs['contractNumber']
        @providedProducts = attrs['providedProducts']

        @sourcePoolId = nil
        @hostId = nil
        @virtOnly = false
        @poolDerived = false
        attrs['attributes'].each do |attr|
          case attr['name']
            when 'source_pool_id'
              @sourcePoolId = attr['value']
            when 'requires_host'
              @hostId = attr['value']
            when 'virt_only'
              @virtOnly = attr['value'] == 'true' ? true : false
            when 'pool_derived'
              @poolDerived = attr['value'] == 'true' ? true : false
          end
        end

        @virtLimit = 0
        @supportType = ""
        @arch = ""
        @supportLevel = ""
        @sockets = 0
        @description = ""
        @productFamily = ""
        @variant = ""
        attrs['productAttributes'].each do |attr|
          case attr['name']
            when 'virt_limit'
              @virtLimit = attr['value'].to_i
            when 'support_type'
              @supportType = attr['value']
            when 'arch'
              @arch = attr['value']
            when 'support_level'
              @supportLevel = attr['value']
            when 'sockets'
              @sockets = attr['value'].to_i
            when 'description'
              @description = attr['value']
            when 'product_family'
              @productFamily = attr['value']
            when 'variant'
              @variant = attr['value']
          end
        end

        super(:cp_id => attrs['id'])
      else
        super
      end
    end

    def organization
      Organization.find_by_name(owner["key"])
    end

  end
end
