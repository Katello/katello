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

module Glue::Candlepin::Owner

  def self.included(base)
    base.send :include, LazyAccessor
    base.send :include, InstanceMethods

    base.class_eval do
      before_save :save_owner_orchestration
      before_destroy :destroy_owner_orchestration

      validates :label,
          :presence => true,
          :format => { :with => /^[\w-]*$/ }

      lazy_accessor :events, :initializer => lambda {|s| Resources::Candlepin::Owner.events(label) }
      lazy_accessor :service_levels, :initializer => lambda {|s| Resources::Candlepin::Owner.service_levels(label) }
      lazy_accessor :debug_cert, :initializer => lambda {|s| load_debug_cert}
    end
  end

  module InstanceMethods

    def serializable_hash(options={})
      hash = super(options)
      hash = hash.merge(:service_levels => self.service_levels)
      hash
    end

    def set_owner
      Rails.logger.debug _("Creating an owner in candlepin: %s") % name
      Resources::Candlepin::Owner.create(label, name)
    rescue => e
      Rails.logger.error _("Failed to create candlepin owner %s") % "#{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_owner
      Rails.logger.debug _("Deleting owner in candlepin: %s") % name
      Resources::Candlepin::Owner.destroy(label)
    rescue => e
      Rails.logger.error _("Failed to delete candlepin owner %s") % "#{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_environments
      Rails.logger.debug _("All environments for owner %s in candlepin") % name
      #need to destroy environments in the proper order to not leave orphans
      self.promotion_paths.each{|path|
        path.reverse.each{|env|
          env.reload.destroy #if we do not reload, the environment may think its successor still exists
        }
      }
      self.library.destroy
      self.library = nil
      return true
    rescue => e
      Rails.logger.error _("Failed to delete all environments for owner %{org} in candlepin: %{message}") % {:org => name, :message => "#{e}, #{e.backtrace.join("\n")}"}
      raise e
    end

    def del_providers
      Rails.logger.debug _("All providers for owner %s in candlepin") % name
      self.providers.destroy_all
    rescue => e
      Rails.logger.error _("Failed to delete all providers for owner %s in candlepin") % [name]
      raise e
    end

    #we must delete all systems as part of org deletion explicitly, otherwise the consumers in
    #  candlepin will be deleted before destroy is called on the Organization object
    def del_systems
      Rails.logger.debug _("All Systems for owner %s in candlepin") % name
      System.joins(:environment).where("environments.organization_id = :org_id", :org_id=>self.id).each do |sys|
        sys.destroy
      end
    rescue => e
      Rails.logger.error _("Failed to delete all systems for owner %{org} in candlepin: %{message}") % {:org => name, :message => "#{e}, #{e.backtrace.join("\n")}"}
      raise e
    end

    def save_owner_orchestration
      case self.orchestration_for
        when :create
          pre_queue.create(:name => "candlepin owner for organization: #{self.name}", :priority => 3, :action => [self, :set_owner])
      end
    end

    def destroy_owner_orchestration
      pre_queue.create(:name => "candlepin systems for organization: #{self.name}", :priority => 2, :action => [self, :del_systems])
      pre_queue.create(:name => "candlepin providers for organization: #{self.name}", :priority => 3, :action => [self, :del_providers])
      pre_queue.create(:name => "candlepin environments for organization: #{self.name}", :priority => 4, :action => [self, :del_environments])
      pre_queue.create(:name => "candlepin owner for organization: #{self.name}", :priority => 5, :action => [self, :del_owner])
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

    def service_level= level
      Resources::Candlepin::Owner.update(self.label, {:defaultServiceLevel=>level})
    end

    def pools consumer_uuid = nil
      if consumer_uuid
        pools = Resources::Candlepin::Owner.pools self.label, { :consumer => consumer_uuid }
      else
        pools = Resources::Candlepin::Owner.pools self.label
      end
      pools.collect { |p| ::Pool.new p }
    end

    def generate_debug_cert
      Resources::Candlepin::Owner.generate_ueber_cert(label)
    end

    def load_debug_cert
      begin
        return Resources::Candlepin::Owner.get_ueber_cert(label)
      rescue RestClient::ResourceNotFound =>  e
        return generate_debug_cert
      end
    end

  end

end
