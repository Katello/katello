#
# Copyright 2013 Red Hat, Inc.
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
      lazy_accessor :remote_data, :pool_derived, :product_name, :consumed, :quantity, :support_level, :support_type,
        :start_date, :end_date, :attrs, :owner, :product_id, :account_number, :contract_number,
        :source_pool_id, :host_id, :virt_only, :virt_limit, :multi_entitlement, :stacking_id,
        :arch, :sockets, :cores, :ram, :description, :product_family, :variant, :provided_products, :instance_multiplier, :suggested_quantity,
        :initializer => lambda {|s|
          json = Resources::Candlepin::Pool.find(cp_id)
          # symbol "attributes" is reserved by Rails and cannot be used
          json['attrs'] = json['attributes']
          json
        }
    end
  end

  module ClassMethods
    def find_by_organization_and_id(organization, pool_id)
      pool = ::Pool.find_by_cp_id(pool_id) || Pool.new(Resources::Candlepin::Pool.find(pool_id))
      if pool.organization == organization
        return pool
      end
    end
  end

  module InstanceMethods

    def initialize(attrs=nil, options={})
      if not attrs.nil? and attrs.member? 'id'
        # initializing from cadlepin json
        load_remote_data(attrs)
        super({:cp_id => attrs['id']}, options)
      else
        super
      end
    end

    def organization
      Organization.find_by_label(self.owner["key"])
    end

    # if defined +load_remote_data+ will be used by +lazy_accessors+
    # to define instance variables
    def load_remote_data(attrs)
      @remote_data = attrs
      @product_name = attrs["productName"]
      @start_date = Date.parse(attrs["startDate"]) if attrs["startDate"]
      @end_date = Date.parse(attrs["endDate"]) if attrs["endDate"]
      @consumed = attrs["consumed"]
      @quantity = attrs["quantity"]
      @attrs = attrs["attributes"]
      @owner = attrs["owner"]
      @product_id = attrs["productId"]
      @cp_id = attrs['id']
      @account_number = attrs['accountNumber']
      @contract_number = attrs['contractNumber']
      @provided_products = attrs['providedProducts']
      @source_pool_id = nil
      @host_id = nil
      @virt_only = false
      @pool_derived = false
      attrs['attributes'].each do |attr|
        case attr['name']
          when 'source_pool_id'
            @source_pool_id = attr['value']
          when 'requires_host'
            @host_id = attr['value']
          when 'virt_only'
            @virt_only = attr['value'] == 'true' ? true : false
          when 'pool_derived'
            @pool_derived = attr['value'] == 'true' ? true : false
        end
      end if attrs['attributes']
      @virt_limit = 0
      @support_type = ""
      @arch = ""
      @support_level = ""
      @sockets = 0
      @ram = 0
      @cores = 0
      @description = ""
      @product_family = ""
      @variant = ""
      @multi_entitlement = false
      @stacking_id = ""
      attrs['productAttributes'].each do |attr|
        case attr['name']
          when 'virt_limit'
            @virt_limit = attr['value'].to_i
          when 'support_type'
            @support_type = attr['value']
          when 'arch'
            @arch = attr['value']
          when 'support_level'
            @support_level = attr['value']
          when 'sockets'
            @sockets = attr['value'].to_i
          when 'cores'
            @cores = attr['value'].to_i
          when 'ram'
            @ram = attr['value'].to_i
          when 'description'
            @description = attr['value']
          when 'product_family'
            @product_family = attr['value']
          when 'variant'
            @variant = attr['value']
          when 'multi-entitlement'
            @multi_entitlement = (attr['value'] == 'true' || attr['value'] == 'yes') ? true : false
          when 'stacking_id'
            @stacking_id = attr['value']
          when 'instance_multiplier'
            @instance_multiplier = attr['value'].to_i
        end
      end if attrs['productAttributes']

      @suggested_quantity = 1
      attrs['calculatedAttributes'].each_key do |key|
        case key
          when 'suggested_quantity'
            @suggested_quantity = attrs['calculatedAttributes']['suggested_quantity'].to_i
        end
      end if attrs['calculatedAttributes']
    end

  end
end
