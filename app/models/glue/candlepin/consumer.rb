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

module Glue::Candlepin::Consumer

  def self.included(base)
    base.send :include, LazyAccessor
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods

    base.class_eval do
      before_save :save_candlepin_orchestration
      before_destroy :destroy_candlepin_orchestration
      after_rollback :rollback_on_candlepin_create, :on => :create

      lazy_accessor :href, :facts, :cp_type, :href, :idCert, :owner, :lastCheckin, :created, :guestIds, :installedProducts, :autoheal, :releaseVer, :serviceLevel,
        :initializer => lambda {|s|
                          if uuid
                            consumer_json = Resources::Candlepin::Consumer.get(uuid)
                            convert_from_cp_fields(consumer_json)
                          end
                        }
      lazy_accessor :entitlements, :initializer => lambda {|s| Resources::Candlepin::Consumer.entitlements(uuid) }
      lazy_accessor :pools, :initializer => lambda {|s| entitlements.collect { |ent| Resources::Candlepin::Pool.find ent["pool"]["id"]} }
      lazy_accessor :available_pools, :initializer => lambda {|s| Resources::Candlepin::Consumer.available_pools(uuid, false) }
      lazy_accessor :all_available_pools, :initializer => lambda {|s| Resources::Candlepin::Consumer.available_pools(uuid, true) }
      lazy_accessor :host, :initializer => lambda {|s|
        host_attributes = Resources::Candlepin::Consumer.host(self.uuid)
        System.new(host_attributes) if host_attributes
      }
      lazy_accessor :guests, :initializer => lambda {|s|
        guests_attributes = Resources::Candlepin::Consumer.guests(self.uuid)
        guests_attributes.map { |attr| System.new(attr) }
      }
      lazy_accessor :compliance, :initializer => lambda {|s| Resources::Candlepin::Consumer.compliance(uuid) }
      lazy_accessor :events, :initializer => lambda {|s| Resources::Candlepin::Consumer.events(uuid) }

      validate :validate_cp_consumer
    end
  end

  module InstanceMethods

    def initialize(attrs=nil, options={})
      # TODO RAILS32 Clean up supers
      if attrs.nil?
        if Rails::VERSION::STRING.start_with?('3.2')
          super
        else
          super(attrs)
        end
      elsif
        type_key = attrs.has_key?('type') ? 'type' : :type
        #rename "type" to "cp_type" (activerecord and candlepin variable name conflict)
        if attrs.has_key?(type_key) && !(attrs.has_key?(:cp_type) || attrs.has_key?('cp_type'))
          attrs[:cp_type] = attrs[type_key]
        end

        attrs_used_by_model = attrs.reject do |k, v|
          !attributes_from_column_definition.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
        end
        if attrs_used_by_model["environment"].is_a? Hash
          attrs_used_by_model.delete("environment")
        end
        if Rails::VERSION::STRING.start_with?('3.2')
          super(attrs_used_by_model, options)
        else
          super(attrs_used_by_model)
        end
      end
    end

    def serializable_hash(options={})
      hash = super(options)
      hash = hash.merge(:serviceLevel => self.serviceLevel)
      hash
    end

    def validate_cp_consumer
      if new_record?
        validates_inclusion_of :cp_type, :in => %w( system hypervisor candlepin )
        validates_presence_of :facts
      end
    end

    def set_candlepin_consumer
      Rails.logger.debug "Creating a consumer in candlepin: #{name}"
      consumer_json = Resources::Candlepin::Consumer.create(self.cp_environment_id,
                                                            self.organization.label,
                                                            self.name, self.cp_type,
                                                            self.facts,
                                                            self.installedProducts,
                                                            self.autoheal,
                                                            self.releaseVer,
                                                            self.serviceLevel)

      load_from_cp(consumer_json)
    rescue => e
      Rails.logger.error "Failed to create candlepin consumer #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def load_from_cp(consumer_json)
      self.uuid = consumer_json[:uuid]
      consumer_json[:facts] ||= {'sockets'=>0}
      convert_from_cp_fields(consumer_json).each do |k,v|
        instance_variable_set("@#{k}", v) if respond_to?("#{k}=")
      end
    end

    def update_candlepin_consumer
      Rails.logger.debug "Updating consumer in candlepin: #{name}"
      Resources::Candlepin::Consumer.update(self.uuid, @facts, @guestIds, @installedProducts, @autoheal,
                                            @releaseVer, self.serviceLevel, self.cp_environment_id)
    rescue => e
      Rails.logger.error "Failed to update candlepin consumer #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_candlepin_consumer
      Rails.logger.debug "Deleting consumer in candlepin: #{name}"
      Resources::Candlepin::Consumer.destroy(self.uuid)
    rescue => e
      Rails.logger.error "Failed to delete candlepin consumer #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def regenerate_identity_certificates
      Rails.logger.debug "Regenerating consumer identity certificates: #{name}"
      Resources::Candlepin::Consumer.regenerate_identity_certificates(self.uuid)
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def get_pool id
      Resources::Candlepin::Pool.find id
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def subscribe pool, quantity = nil
      Rails.logger.debug "Subscribing to pool '#{pool}' for : #{name}"
      Resources::Candlepin::Consumer.consume_entitlement self.uuid, pool, quantity
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def export
      Rails.logger.debug "Exporting manifest"
      Resources::Candlepin::Consumer.export self.uuid
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def unsubscribe entitlement
      Rails.logger.debug "Unsubscribing from entitlement '#{entitlement}' for : #{name}"
      Resources::Candlepin::Consumer.remove_entitlement self.uuid, entitlement
      #ents = self.entitlements.collect {|ent| ent["id"] if ent["pool"]["id"] == pool}.compact
      #raise ArgumentError, "Not subscribed to the pool #{pool}" if ents.count < 1
      #ents.each { |ent|
      #  Resources::Candlepin::Consumer.remove_entitlement self.uuid, ent
      #}
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def unsubscribe_by_serial serial
      Rails.logger.debug "Unsubscribing from certificate '#{serial}' for : #{name}"
      Resources::Candlepin::Consumer.remove_certificate self.uuid, serial
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def unsubscribe_all
      Rails.logger.debug "Unsubscribing from all entitlements for : #{name}"
      Resources::Candlepin::Consumer.remove_entitlements self.uuid
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def to_json
      super(:methods => [:href, :facts, :idCert, :owner, :autoheal, :release, :releaseVer])
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

    # A rollback occurred while attempting to create the consumer; therefore, perform necessary cleanup.
    def rollback_on_candlepin_create
      del_candlepin_consumer
    end

    def cp_environment_id
      if self.content_view
        self.content_view.cp_environment_id(self.environment)
      else
        self.environment_id
      end
    end

    def hostname
      facts["network.hostname"]
    end

    # interface listings come in the form of
    #
    # net.interface.em1.ipv4_address
    # net.interface.eth0.ipv4_broadcast
    #
    # there are multiple entries for each interface, but
    # we only need the ipv4 address
    def interfaces
      interfaces = []
      facts.keys.each do |key|
        match = /net\.interface\.([^\.]*)/.match(key)
        if !match.nil? && !match[1].nil?
          interfaces << match[1]
        end
      end
      interface_set = []
      interfaces.uniq.each do |interface|
        addr = facts["net.interface.#{interface}.ipv4_address"]
        # older subman versions report .ipaddr
        addr ||= facts["net.interface.#{interface}.ipaddr"]
        interface_set << { :name => interface, :addr => addr } if addr != nil
      end
      interface_set
    end

    def ip
      facts['network.ipv4_address']
    end

    def kernel
      facts["uname.release"]
    end

    def arch
      facts["uname.machine"] if @facts
    end

    def arch=(arch)
      facts["uname.machine"] = arch if @facts
    end

    # Sockets are required to have a value in katello for searching as well as for checking subscription limits
    # Force always to an integer value for consistency
    def sockets
      s = @facts ? Integer(facts["cpu.cpu_socket(s)"]) : 0
    rescue
      0
    end

    def sockets=(sock)
      s = Integer(sock) rescue 0

      facts["cpu.cpu_socket(s)"] = s if @facts
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

    def memory
      if facts
        mem = facts["memory.memtotal"]
        # dmi.memory.size is on older clients
        mem ||= facts["dmi.memory.size"]
      else
        mem = '0'
      end
      memory_in_megabytes(mem)
    end

    def memory=(mem)
      mem = "#{mem.to_i} MB"
      facts["memory.memtotal"] = mem
    end

    def entitlements_valid?
      "true" == facts["system.entitlements_valid"]
    end

    def checkinTime
      if lastCheckin
        convert_time(lastCheckin)
      end
    end

    def createdTime
      if created
        convert_time(created)
      end
    end

    def convert_time(item)
      Time.parse(item)
    end

    def release
      if self.releaseVer.is_a? Hash
         self.releaseVer["releaseVer"]
      else
        self.releaseVer
      end
    end

    def memory_in_megabytes(mem_str)
      # convert total memory into megabytes
      return 0 if mem_str.nil?
      mem,unit = mem_str.split
      total_mem = mem.to_f
      case unit
        when 'B'  then total_mem = 0
        when 'kB' then total_mem = (total_mem / 1024)
        when 'MB' then total_mem *= 1
        when 'GB' then total_mem *= (1024)
        when 'TB' then total_mem *= (1024*1024)
        # default memtotal is in kB
        else total_mem = (total_mem / 1024)
      end
      total_mem.to_i
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
        supportLevel = ""
        pool["productAttributes"].each do |attr|
          if attr["name"] == "sockets"
            sockets = attr["value"]
          elsif attr["name"] == "multi-entitlement"
            multiEntitlement = true
          elsif attr["name"] == "support_level"
            supportLevel = attr["value"]
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
                       :endDate => Date.parse(pool["endDate"]),
                       :startDate => Date.parse(pool["startDate"]),
                       :consumed => pool["consumed"],
                       :quantity => pool["quantity"],
                       :sockets => sockets,
                       :supportLevel => supportLevel,
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
        sockets = ""
        pool["productAttributes"].each do |attr|
          if attr["name"] == "support_level"
            sla = attr["value"]
          elsif attr["name"] == "sockets"
            sockets = attr["value"]
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
                       :poolId => entitlement["pool"]["id"],
                       :serials => serials,
                       :poolName => pool["productName"],
                       :consumed => pool["consumed"],
                       :quantity => quantity,
                       :sla => sla,
                       :sockets => sockets,
                       :endDate => Date.parse(pool["endDate"]),
                       :startDate => Date.parse(pool["startDate"]),
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

    def all_by_pool(pool_id)
      entitlements = Resources::Candlepin::Entitlement.get
      system_uuids = entitlements.delete_if{|ent| ent["pool"]["id"] != pool_id }.map{|ent| ent["consumer"]["uuid"]}
      return where(:uuid => system_uuids)
    end

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
      consumers_attrs = Resources::Candlepin::Consumer.register_hypervisors(hypervisors_attrs)
      created = consumers_attrs[:created].map do |hypervisor_attrs|
        System.create_hypervisor(environment.id, hypervisor_attrs)
      end
      return consumers_attrs, created
    end
  end

end
