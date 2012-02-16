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

require 'resources/candlepin'

module Glue::Candlepin::Consumer

  def self.included(base)
    base.send :include, LazyAccessor
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods

    base.class_eval do
      before_save :save_candlepin_orchestration
      before_destroy :destroy_candlepin_orchestration

      lazy_accessor :href, :facts, :cp_type, :href, :idCert, :owner, :lastCheckin, :created, :guestIds, :installedProducts, :autoheal,
        :initializer => lambda {
                          if uuid
                            consumer_json = Candlepin::Consumer.get(uuid)
                            convert_from_cp_fields(consumer_json)
                          end
                        }
      lazy_accessor :entitlements, :initializer => lambda { Candlepin::Consumer.entitlements(uuid) }
      lazy_accessor :pools, :initializer => lambda { entitlements.collect { |ent| Candlepin::Pool.get ent["pool"]["id"]} }
      lazy_accessor :available_pools, :initializer => lambda { Candlepin::Consumer.available_pools(uuid, false) }
      lazy_accessor :all_available_pools, :initializer => lambda { Candlepin::Consumer.available_pools(uuid, true) }
      lazy_accessor :host, :initializer => lambda {
        host_attributes = Candlepin::Consumer.host(self.uuid)
        System.new(host_attributes) if host_attributes
      }
      lazy_accessor :guests, :initializer => lambda {
        guests_attributes = Candlepin::Consumer.guests(self.uuid)
        guests_attributes.map { |attr| System.new(attr) }
      }
      lazy_accessor :compliance, :initializer => lambda { Candlepin::Consumer.compliance(uuid) }
      lazy_accessor :events, :initializer => lambda { Candlepin::Consumer.events(uuid) }

      validate :validate_cp_consumer
    end
  end

  module InstanceMethods

    def initialize(attrs = nil)
      if attrs.nil?
        super
      elsif
        type_key = attrs.has_key?('type') ? 'type' : :type
        #rename "type" to "cp_type" (activerecord and candlepin variable name conflict)
        if attrs.has_key?(type_key) && !(attrs.has_key?(:cp_type) || attrs.has_key?('cp_type'))
          attrs[:cp_type] = attrs[type_key]
        end

        attrs_used_by_model = attrs.reject do |k, v|
          !attributes_from_column_definition.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
        end
        super(attrs_used_by_model)
      end
    end

    def validate_cp_consumer
      if new_record?
        validates_inclusion_of :cp_type, :in => %w( system hypervisor)
        validates_presence_of :facts
      end
    end

    def set_candlepin_consumer
      Rails.logger.debug "Creating a consumer in candlepin: #{name}"
      consumer_json = Candlepin::Consumer.create(self.environment_id,
                                                 self.organization.cp_key,
                                                 self.name, self.cp_type,
                                                 self.facts,
                                                 self.installedProducts,
                                                 self.autoheal)

      load_from_cp(consumer_json)
    rescue => e
      Rails.logger.error "Failed to create candlepin consumer #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def load_from_cp(consumer_json)
      self.uuid = consumer_json[:uuid]
      convert_from_cp_fields(consumer_json).each do |k,v|
        instance_variable_set("@#{k}", v) if respond_to?("#{k}=")
      end
    end

    def update_candlepin_consumer
      Rails.logger.debug "Updating consumer in candlepin: #{name}"
      Candlepin::Consumer.update(self.uuid, @facts, @guestIds, @installedProducts, @autoheal)
    rescue => e
      Rails.logger.error "Failed to update candlepin consumer #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_candlepin_consumer
      Rails.logger.debug "Deleting consumer in candlepin: #{name}"
      Candlepin::Consumer.destroy(self.uuid)
    rescue => e
      Rails.logger.error "Failed to delete candlepin consumer #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def regenerate_identity_certificates
      Rails.logger.debug "Regenerating consumer identity certificates: #{name}"
      Candlepin::Consumer.regenerate_identity_certificates(self.uuid)
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def get_pool id
      Candlepin::Pool.get id
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def subscribe pool, quantity = nil
      Rails.logger.debug "Subscribing to pool '#{pool}' for : #{name}"
      Candlepin::Consumer.consume_entitlement self.uuid, pool, quantity
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def unsubscribe entitlement
      Rails.logger.debug "Unsubscribing from entitlement '#{entitlement}' for : #{name}"
      Candlepin::Consumer.remove_entitlement self.uuid, entitlement
      #ents = self.entitlements.collect {|ent| ent["id"] if ent["pool"]["id"] == pool}.compact
      #raise ArgumentError, "Not subscribed to the pool #{pool}" if ents.count < 1
      #ents.each { |ent|
      #  Candlepin::Consumer.remove_entitlement self.uuid, ent
      #}
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def unsubscribe_by_serial serial
      Rails.logger.debug "Unsubscribing from certificate '#{serial}' for : #{name}"
      Candlepin::Consumer.remove_certificate self.uuid, serial
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def unsubscribe_all
      Rails.logger.debug "Unsubscribing from all entitlements for : #{name}"
      Candlepin::Consumer.remove_entitlements self.uuid
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def to_json
      super(:methods => [:href, :facts, :idCert, :owner, :autoheal])
    end

    def convert_from_cp_fields(cp_json)
      cp_json.merge(:cp_type => cp_json.delete(:type)) if cp_json.has_key?(:type)
      reject_db_columns(cp_json)
    end

    def reject_db_columns(cp_json)
      cp_json.reject {|k,v| attributes_from_column_definition.keys.member?(k.to_s) }
    end

    def save_candlepin_orchestration
      case orchestration_for
        when :hypervisor
          # it's already saved = do nothing
        when :create
          pre_queue.create(:name => "create candlepin consumer: #{self.name}", :priority => 2, :action => [self, :set_candlepin_consumer])
        when :update
          pre_queue.create(:name => "update candlepin consumer: #{self.name}", :priority => 3, :action => [self, :update_candlepin_consumer])
      end
    end

    def destroy_candlepin_orchestration
      pre_queue.create(:name => "delete candlepin consumer: #{self.name}", :priority => 3, :action => [self, :del_candlepin_consumer])
    end

    def hostname
      facts["network.hostname"]
    end

    def ip
      facts.keys().grep(/eth.*ipaddr/).collect { |k| facts[k]}.first
    end

    def kernel
      facts["uname.release"]
    end

    def arch
      facts["uname.machine"]
    end

    def arch=(arch)
      facts["uname.machine"] = arch if @facts
    end

    def sockets
      facts["cpu.cpu_socket(s)"]
    end

    def sockets=(sock)
      facts["cpu.cpu_socket(s)"] = sock if @facts
    end

    def guest
      facts["virt.is_guest"]
    end

    def guest=(val)
      facts["virt.is_guest"] = val if @facts
    end

    def name=(val)
      super(val)
      facts["network.hostname"] = val if @facts
    end

    def distribution_name
      facts["distribution.name"]
    end

    def distribution_version
      facts["distribution.version"]
    end

    def distribution
      "#{distribution_name} #{distribution_version}"
    end

    def entitlements_valid?
      "true" == facts["system.entitlements_valid"]
    end

    def checkinTime
      if lastCheckin
        convert_time(lastCheckin)
      end
    end

    def convert_time(item)
      Time.parse(item)
    end

    def available_pools_full listall=false

      # The available pools can be constrained to match the system (number of sockets, etc.), or
      # all of the pools that could be applied to the system, even if not a perfect match.
      if listall
        pools = self.all_available_pools
      else
        pools = self.available_pools
      end
      avail_pools = pools.collect {|pool|
        sockets = ""
        multiEntitlement = false
        pool["productAttributes"].each do |attr|
          if attr["name"] == "socket_limit"
            sockets = attr["value"]
          elsif attr["name"] == "multi-entitlement"
            multiEntitlement = true
          end
        end

        providedProducts = []
        pool["providedProducts"].each do |cp_product|
          product = ::Product.where(:cp_id => cp_product["productId"]).first
          if product
            providedProducts << product
          end
        end

        OpenStruct.new(:poolId => pool["id"],
                       :poolName => pool["productName"],
                       :expires => Date.parse(pool["endDate"]),
                       :consumed => pool["consumed"],
                       :quantity => pool["quantity"],
                       :sockets => sockets,
                       :multiEntitlement => multiEntitlement,
                       :providedProducts => providedProducts)
      }
      avail_pools.sort! {|a,b| a.poolName <=> b.poolName}
      avail_pools
    end

    def consumed_entitlements
      consumed_entitlements = self.entitlements.collect { |entitlement|

        pool = self.get_pool entitlement["pool"]["id"]

        sla = ""
        pool["productAttributes"].each do |attr|
          if attr["name"] == "support_level"
            sla = attr["value"]
            break
          end
        end

        providedProducts = []
        pool["providedProducts"].each do |cp_product|
          product = ::Product.where(:cp_id => cp_product["productId"]).first
          if product
            providedProducts << product
          end
        end

        quantity = entitlement["quantity"] != nil ? entitlement["quantity"] : pool["quantity"]

        serials = []
        entitlement['certificates'].each do |certificate|
          if certificate.has_key?('serial')
            serials << certificate['serial']
          end
        end

        OpenStruct.new(:entitlementId => entitlement["id"],
                       :serials => serials,
                       :poolName => pool["productName"],
                       :expires => Date.parse(pool["endDate"]),
                       :consumed => pool["consumed"],
                       :quantity => quantity,
                       :sla => sla,
                       :contractNumber => pool["contractNumber"],
                       :providedProducts => providedProducts)
      }
      consumed_entitlements.sort! {|a,b| a.poolName <=> b.poolName}
      consumed_entitlements
    end

    def compliant?
      return self.compliance['compliant'] == true
    end

    # As a convenience and common terminology 
    def compliance_color
      return 'green' if self.compliant?
      return 'yellow' if self.compliance['partiallyCompliantProducts'].length > 0 && self.compliance['nonCompliantProducts'].length == 0
      return 'red'
    end

    def compliant_until
      if self.compliance['compliantUntil']
        Date.parse(self.compliance['compliantUntil'])
      end
    end

    def product_compliance_color product_id
      return 'green' if self.compliance['compliantProducts'].include? product_id
      return 'yellow' if self.compliance['partiallyCompliantProducts'].include? product_id
      return 'red'
    end
  end

  module ClassMethods

    def create_hypervisor(environment_id, hypervisor_json)
      hypervisor = Hypervisor.new(:environment_id => environment_id)
      hypervisor.name = hypervisor_json[:name]
      hypervisor.cp_type = 'hypervisor'
      hypervisor.orchestration_for = :hypervisor
      hypervisor.load_from_cp(hypervisor_json)
      hypervisor.save!
      hypervisor
    end

    def register_hypervisors(environment, hypervisors_attrs)
      consumers_attrs = Candlepin::Consumer.register_hypervisors(hypervisors_attrs)
      created = consumers_attrs[:created].map do |hypervisor_attrs|
        System.create_hypervisor(environment.id, hypervisor_attrs)
      end
      return consumers_attrs, created
    end
  end

end
