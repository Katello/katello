module Katello
  module Glue::Candlepin::Consumer
    SYSTEM = "system"
    HYPERVISOR = "hypervisor"
    CANDLEPIN = "candlepin"
    CP_TYPES = [SYSTEM, HYPERVISOR, CANDLEPIN]

    # TODO: break up method
    def self.included(base) # rubocop:disable MethodLength
      base.send :include, LazyAccessor
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods

      base.class_eval do
        lazy_accessor :href, :facts, :cp_type, :idCert, :owner, :lastCheckin, :created, :guestIds,
        :installedProducts, :autoheal, :releaseVer, :serviceLevel, :capabilities, :entitlementStatus,
        :initializer => :candlepin_consumer_info

        lazy_accessor :candlepin_consumer_info, :initializer =>
                        (lambda do |_s|
                          if uuid
                            consumer_json = Resources::Candlepin::Consumer.get(uuid)
                            convert_from_cp_fields(consumer_json)
                          end
                        end)

        lazy_accessor :entitlements, :initializer => lambda { |_s| Resources::Candlepin::Consumer.entitlements(uuid) }
        lazy_accessor :pools, :initializer => lambda { |_s| entitlements.collect { |ent| Resources::Candlepin::Pool.find ent["pool"]["id"] } }
        lazy_accessor :available_pools, :initializer => lambda { |_s| Resources::Candlepin::Consumer.available_pools(uuid, false) }
        lazy_accessor :all_available_pools, :initializer => lambda { |_s| Resources::Candlepin::Consumer.available_pools(uuid, true) }
        lazy_accessor :virtual_host, :initializer => (lambda do |_s|
                                                        host_attributes = Resources::Candlepin::Consumer.virtual_host(self.uuid)
                                                        (System.find_by_uuid(host_attributes['uuid']) || System.new(host_attributes)) if host_attributes
                                                      end)
        lazy_accessor :virtual_guests, :initializer => (lambda do |_s|
                                                          guests_attributes = Resources::Candlepin::Consumer.virtual_guests(self.uuid)
                                                          guests_attributes.map do |attr|
                                                            System.find_by_uuid(attr['uuid']) || System.new(attr)
                                                          end
                                                        end)
        lazy_accessor :compliance, :initializer => lambda { |_s| Resources::Candlepin::Consumer.compliance(uuid) }
        lazy_accessor :events, :initializer => lambda { |_s| Resources::Candlepin::Consumer.events(uuid) }

        validates :cp_type, :inclusion => {:in => CP_TYPES},
                            :if => :new_record?
        validates :facts, :presence => true, :if => :new_record?
      end
    end

    module InstanceMethods
      def initialize(attrs = nil, options = {})
        if attrs.nil?
          super
        else
          type_key = attrs.key?('type') ? 'type' : :type
          #rename "type" to "cp_type" (activerecord and candlepin variable name conflict)
          if attrs.key?(type_key) && !(attrs.key?(:cp_type) || attrs.key?('cp_type'))
            attrs[:cp_type] = attrs[type_key]
          end

          attrs_used_by_model = attrs.reject do |k, _v|
            !self.class.column_defaults.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
          end
          if attrs_used_by_model["environment"].is_a? Hash
            attrs_used_by_model.delete("environment")
          end

          super(attrs_used_by_model, options)
        end
      end

      def load_from_cp(consumer_json)
        self.uuid = consumer_json[:uuid]
        consumer_json[:facts] ||= {'sockets' => 0}
        convert_from_cp_fields(consumer_json).each do |k, v|
          instance_variable_set("@#{k}", v) if respond_to?("#{k}=")
        end
      end

      def checkin(checkin_time)
        Rails.logger.debug "Updating consumer check-in time: #{name}"
        Resources::Candlepin::Consumer.checkin(self.uuid, checkin_time)
      rescue => e
        Rails.logger.error "Failed to update consumer check-in time in candlepin for #{name}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end

      def regenerate_identity_certificates
        Rails.logger.debug "Regenerating consumer identity certificates: #{name}"
        Resources::Candlepin::Consumer.regenerate_identity_certificates(self.uuid)
      rescue => e
        Rails.logger.debug e.backtrace.join("\n\t")
        raise e
      end

      def get_pool(id)
        Resources::Candlepin::Pool.find id
      rescue => e
        Rails.logger.debug e.backtrace.join("\n\t")
        raise e
      end

      def subscribe(pool, quantity = nil)
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

      def unsubscribe(entitlement)
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

      def unsubscribe_by_serial(serial)
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

      def to_json(options = {})
        super(options.merge(:methods => [:href, :facts, :idCert, :owner, :autoheal, :release, :releaseVer, :checkin_time,
                                         :installedProducts, :capabilities]))
      end

      def convert_from_cp_fields(cp_json)
        cp_json.merge!(:cp_type => cp_json.delete(:type)[:label]) if cp_json.key?(:type)
        cp_json = reject_db_columns(cp_json)

        cp_json[:guestIds] = remove_hibernate_fields(cp_json[:guestIds]) if cp_json.key?(:guestIds)
        cp_json[:installedProducts] = remove_hibernate_fields(cp_json[:installedProducts]) if cp_json.key?(:installedProducts)

        cp_json
      end

      # Candlepin sends back its internal hibernate fields in the json. However it does not accept them in return
      # when updating (PUT) objects.
      def remove_hibernate_fields(elements)
        return nil unless elements
        elements.collect { |e| e.except(:id, :created, :updated) }
      end

      def reject_db_columns(cp_json)
        cp_json.reject { |k, _v| self.class.column_defaults.keys.member?(k.to_s) }
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

      def interfaces
        Katello::System.interfaces(facts)
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
        @facts ? Integer(facts["cpu.cpu_socket(s)"]) : 0
      rescue
        0
      end

      def sockets=(sock)
        s = Integer(sock) rescue 0

        facts["cpu.cpu_socket(s)"] = s if @facts
      end

      def virtual_guest
        ::Foreman::Cast.to_bool(facts["virt.is_guest"])
      end

      def virtual_guest=(val)
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
        memory_in_gigabytes(mem.to_s)
      end

      def memory=(mem)
        mem = "#{mem.to_i} MB"
        facts["memory.memtotal"] = mem
      end

      def entitlements_valid?
        "true" == facts["system.entitlements_valid"]
      end

      def checkin_time
        if lastCheckin
          convert_time(lastCheckin)
        end
      end

      def created_time
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

      def memory_in_gigabytes(mem_str)
        # convert total memory into gigabytes
        return 0 if mem_str.nil?
        mem, unit = mem_str.split
        total_mem = mem.to_f
        case unit
        when 'B'  then total_mem = 0
        when 'kB' then total_mem = 0
        when 'MB' then total_mem /= 1024
        when 'GB' then total_mem *= 1
        when 'TB' then total_mem *= 1024
          # default memtotal is in kB
        else total_mem = (total_mem / (1024 * 1024))
        end
        total_mem.round(2)
      end

      # TODO: break up method
      # rubocop:disable MethodLength
      def available_pools_full(listall = false)
        # The available pools can be constrained to match the system (number of sockets, etc.), or
        # all of the pools that could be applied to the system, even if not a perfect match.
        if listall
          pools = self.all_available_pools
        else
          pools = self.available_pools
        end
        avail_pools = pools.collect do |pool|
          sockets = ""
          multi_entitlement = false
          support_level = ""
          pool["productAttributes"].each do |attr|
            if attr["name"] == "sockets"
              sockets = attr["value"]
            elsif attr["name"] == "multi-entitlement"
              multi_entitlement = true
            elsif attr["name"] == "support_level"
              support_level = attr["value"]
            end
          end

          provided_products = []
          pool['providedProducts'].each do |cp_product|
            product = Katello::Product.where(:cp_id => cp_product["productId"]).first
            if product
              provided_products << product
            end
          end

          OpenStruct.new(:poolId => pool["id"],
                         :poolName => pool["productName"],
                         :endDate => Date.parse(pool["endDate"]),
                         :startDate => Date.parse(pool["startDate"]),
                         :consumed => pool["consumed"],
                         :quantity => pool["quantity"],
                         :sockets => sockets,
                         :supportLevel => support_level,
                         :multiEntitlement => multi_entitlement,
                         :providedProducts => provided_products)
        end
        avail_pools.sort! { |a, b| a.poolName <=> b.poolName }
        avail_pools
      end

      def consumed_entitlements
        self.entitlements.collect do |entitlement|
          pool = self.get_pool(entitlement['pool']['id'])
          entitlement_pool = Katello::Pool.new(pool)
          entitlement_pool.cp_id = entitlement['id']
          entitlement_pool.subscription_id = entitlement['pool']['id']
          entitlement_pool.amount = entitlement['quantity']
          entitlement_pool
        end
      end

      def set_content_override(content_label, name, value = nil)
        Resources::Candlepin::Consumer.update_content_override(self.uuid, content_label, name, value)
      end

      def content_overrides
        Resources::Candlepin::Consumer.content_overrides(self.uuid)
      end

      def compliant?
        self.compliance['compliant']
      end

      # As a convenience and common terminology
      def compliance_color
        return 'green' if self.compliance['status'] == 'valid'
        return 'red' if self.compliance['status'] == 'invalid'
        return 'yellow' if self.compliance['status'] == 'partial'
        return 'red'
      end

      def compliant_until
        if self.compliance['compliantUntil']
          Date.parse(self.compliance['compliantUntil'])
        end
      end

      def product_compliance_color(product_id)
        return 'green' if self.compliance['compliantProducts'].include? product_id
        return 'yellow' if self.compliance['partiallyCompliantProducts'].include? product_id
        return 'red'
      end

      def import_candlepin_tasks
        self.events.each do |event|
          event_status = {:task_id => event[:id],
                          :state => event[:type],
                          :start_time => event[:timestamp],
                          :finish_time => event[:timestamp],
                          :progress => "100",
                          :result => event[:messageText]}
          unless self.task_statuses.where('katello_task_statuses.uuid' => event_status[:task_id]).exists?
            TaskStatus.make(self, event_status, :candlepin_event, :event => event)
          end
        end
      end

      def populate_from(candlepin_systems)
        found = candlepin_systems.find { |system| system['uuid'] == self.uuid }
        prepopulate(found.with_indifferent_access) if found
        !found.nil?
      end

      def products
        all_products = []

        self.entitlements.each do |entitlement|
          pool = Katello::Pool.find_pool(entitlement['pool']['id'])
          Katello::Product.where(:cp_id => pool.product_id).each do |product|
            if product.is_a? Katello::MarketingProduct
              all_products += product.engineering_products
            else
              all_products << product
            end
          end
        end

        return all_products
      end
    end

    module ClassMethods
      def prepopulate!(systems)
        uuids = systems.collect { |system| [:uuid, system.uuid] }
        items = Resources::Candlepin::Consumer.get(uuids)
        systems.each { |system| system.populate_from(items) }
      end

      def all_by_pool(pool_id)
        entitlements = Resources::Candlepin::Entitlement.get
        system_uuids = entitlements.delete_if { |ent| ent["pool"]["id"] != pool_id }.map { |ent| ent["consumer"]["uuid"] }
        return where(:uuid => system_uuids)
      end

      def all_by_pool_uuid(pool_id)
        entitlements = Resources::Candlepin::Entitlement.get
        system_uuids = entitlements.delete_if { |ent| ent["pool"]["id"] != pool_id }.map { |ent| ent["consumer"]["uuid"] }
        return system_uuids
      end

      def create_hypervisor(environment_id, content_view_id, hypervisor_json)
        hypervisor = Hypervisor.new(:environment_id => environment_id, :content_view_id => content_view_id)
        hypervisor.name = hypervisor_json[:name]
        hypervisor.cp_type = 'hypervisor'
        hypervisor.orchestration_for = :hypervisor
        hypervisor.load_from_cp(hypervisor_json)
        hypervisor.save!
        hypervisor
      end

      def register_hypervisors(environment, content_view, hypervisors_attrs)
        consumers_attrs = Resources::Candlepin::Consumer.register_hypervisors(hypervisors_attrs)
        created = []
        if consumers_attrs[:created]
          consumers_attrs[:created].each do |hypervisor|
            created << System.create_hypervisor(environment.id, content_view.id, hypervisor)
          end
        end
        if consumers_attrs[:updated]
          consumers_attrs[:updated].each do |hypervisor|
            unless System.find_by_uuid(hypervisor[:uuid])
              created << System.create_hypervisor(environment.id, content_view.id, hypervisor)
            end
          end
        end
        if consumers_attrs[:unchanged]
          consumers_attrs[:unchanged].each do |hypervisor|
            unless System.find_by_uuid(hypervisor[:uuid])
              created << System.create_hypervisor(environment.id, content_view.id, hypervisor)
            end
          end
        end
        return consumers_attrs, created
      end

      # interface listings come in the form of
      #
      # net.interface.em1.ipv4_address
      # net.interface.eth0.ipv4_broadcast
      #
      # there are multiple entries for each interface, but
      # we only need the ipv4 and mac addresses
      def interfaces(facts)
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
          mac = facts["net.interface.#{interface}.mac_address"]
          interface_set << { :name => interface, :addr => addr, :mac => mac } if !addr.nil? || !mac.nil?
        end
        interface_set
      end
    end
  end
end
