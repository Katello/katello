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

module Glue::Candlepin::Owner

  def self.included(base)
    base.send :include, LazyAccessor
    base.send :include, InstanceMethods

    base.class_eval do
      before_save :save_owner_orchestration
      before_destroy :destroy_owner_orchestration

      validates :cp_key,
          :presence => true,
          :format => { :with => /^[\w-]*$/ }

      lazy_accessor :events, :initializer => lambda { Candlepin::Owner.events(cp_key) }
      lazy_accessor :debug_cert, :initializer => lambda { load_debug_cert}
    end
  end

  module InstanceMethods
    def set_owner
      Rails.logger.info "Creating an owner in candlepin: #{name}"
      Candlepin::Owner.create(cp_key, name)
    rescue => e
      Rails.logger.error "Failed to create candlepin owner #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_owner
      Rails.logger.info "Deleteing owner in candlepin: #{name}"
      Candlepin::Owner.destroy(cp_key)
    rescue => e
      Rails.logger.error "Failed to delete candlepin owner #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end
        

    def del_providers
      Rails.logger.info "All providers for owner #{name} in candlepin"
      self.providers.each do |provider|
        provider.destroy
      end
    rescue => e
      Rails.logger.error "Failed to delete all providers for owner #{name} in candlepin: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    #we must delete all systems as part of org deletion explicitly, otherwise the consumers in
    #  candlepin will be deleted before destroy is called on the Organization object 
    def del_systems
      Rails.logger.info "All Systems for owner #{name} in candlepin"
      System.joins(:environment).where("environments.organization_id = :org_id", :org_id=>self.id).each do |sys|
        sys.destroy
      end
    rescue => e
      Rails.logger.error "Failed to delete all systems for owner #{name} in candlepin: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def save_owner_orchestration
      case self.orchestration_for
        when :create
          queue.create(:name => "candlepin owner for organization: #{self.name}", :priority => 3, :action => [self, :set_owner])
      end
    end

    def destroy_owner_orchestration
      queue.create(:name => "candlepin systems for organization: #{self.name}", :priority => 2, :action => [self, :del_systems])
      queue.create(:name => "candlepin providers for organization: #{self.name}", :priority => 3, :action => [self, :del_providers])
      queue.create(:name => "candlepin owner for organization: #{self.name}", :priority => 4, :action => [self, :del_owner])
    end

    def owner_info
      Glue::Candlepin::OwnerInfo.new(self)
    end

    def pools consumer_uuid = nil
      if consumer_uuid
        pools = Candlepin::Owner.pools self.cp_key, { :consumer => consumer_uuid }
      else
        pools = Candlepin::Owner.pools self.cp_key
      end
      pools.collect { |p| KTPool.new p }
    end

    def generate_debug_cert
      Candlepin::Owner.generate_ueber_cert(cp_key)
    end

    def load_debug_cert
      begin
        return Candlepin::Owner.get_ueber_cert(cp_key)
      rescue RestClient::ResourceNotFound =>  e
        return generate_debug_cert
      end
    end

  end

end
