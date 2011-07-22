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

    base.class_eval do
      before_save :save_candlepin_orchestration
      before_destroy :destroy_candlepin_orchestration

      lazy_accessor :href, :facts, :cp_type, :href, :idCert, :owner, :lastCheckin, :created, :initializer => lambda { consumer_json = Candlepin::Consumer.get(uuid); convert_from_cp_fields(consumer_json) }
      lazy_accessor :entitlements, :initializer => lambda { Candlepin::Consumer.entitlements(uuid) }
      lazy_accessor :pools, :initializer => lambda { entitlements.collect { |ent| Candlepin::Pool.get ent["pool"]["id"]} }
      lazy_accessor :available_pools, :initializer => lambda { Candlepin::Consumer.available_pools(uuid) }
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

    def validate
      if new_record?
        validates_inclusion_of :cp_type, :in => %w( system )
        validates_presence_of :facts
      end
    end

    def set_candlepin_consumer
      Rails.logger.info "Creating a consumer in candlepin: #{name}"
      consumer_json = Candlepin::Consumer.create(self.organization.cp_key, self.name, self.cp_type, self.facts)

      self.uuid = consumer_json[:uuid]
      convert_from_cp_fields(consumer_json).each do |k,v|
        instance_variable_set("@#{k}", v) if respond_to?("#{k}=")
      end
    rescue => e
      Rails.logger.error "Failed to create candlepin consumer #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def update_candlepin_consumer
      return true if @facts.nil?

      Rails.logger.info "Updating consumer in candlepin: #{name}"
      Candlepin::Consumer.update(self.uuid, self.facts)
    rescue => e
      Rails.logger.error "Failed to update candlepin consumer #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_candlepin_consumer
      Rails.logger.info "Deleteing consumer in candlepin: #{name}"
      Candlepin::Consumer.destroy(self.uuid)
    rescue => e
      Rails.logger.error "Failed to delete candlepin consumer #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def regenerate_identity_certificates
      Rails.logger.info "Regenerating consumer identity certificates: #{name}"
      Candlepin::Consumer.regenerate_identity_certificates(self.uuid)
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def subscribe pool
      Rails.logger.info "Subscribing to pool '#{pool}' for : #{name}"
      Candlepin::Consumer.consume_entitlement self.uuid, pool
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def unsubscribe pool
      Rails.logger.info "Unsubscribing to pool '#{pool}' for : #{name}"
      ents = self.entitlements.collect {|ent| ent["id"] if ent["pool"]["id"] == pool}.compact
      ents.each { |ent|
        Candlepin::Consumer.remove_entitlement self.uuid, ent        
      }
    rescue => e
      Rails.logger.debug e.backtrace.join("\n\t")
      raise e
    end

    def to_json
      super(:methods => [:href, :facts, :idCert, :owner])
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
        when :create
          queue.create(:name => "create candlepin consumer: #{self.name}", :priority => 2, :action => [self, :set_candlepin_consumer])
        when :update
          queue.create(:name => "update candlepin consumer: #{self.name}", :priority => 3, :action => [self, :update_candlepin_consumer])
      end
    end

    def destroy_candlepin_orchestration
      queue.create(:name => "delete candlepin consumer: #{self.name}", :priority => 3, :action => [self, :del_candlepin_consumer])
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
    
    def distro
      facts["distribution.name"]
    end
    
  end

end
