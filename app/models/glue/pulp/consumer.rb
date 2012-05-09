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

require_dependency "resources/pulp" if AppConfig.katello?

module Glue::Pulp::Consumer
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :include, LazyAccessor
    base.class_eval do
      before_save :save_pulp_orchestration
      before_destroy :destroy_pulp_orchestration
      lazy_accessor :pulp_facts, :initializer => lambda { Pulp::Consumer.find(uuid) }
      lazy_accessor :package_profile, :initializer => lambda { Pulp::Consumer.installed_packages(uuid) }
      lazy_accessor :simple_packages, :initializer => lambda { Pulp::Consumer.installed_packages(uuid).
                                                              collect{|pack| Glue::Pulp::SimplePackage.new(pack)} }
      lazy_accessor :errata, :initializer => lambda { Pulp::Consumer.errata(uuid).
                                                              collect{|errata| Glue::Pulp::Errata.new(errata)} }
      lazy_accessor :repoids, :initializer => lambda { Pulp::Consumer.repoids(uuid).keys }
    end
  end

  module InstanceMethods
    def enable_repos update_ids
      # calculate repoids to bind/unbind
      bound_ids = repoids
      intersection = update_ids & bound_ids
      bind_ids = update_ids - intersection
      unbind_ids = bound_ids - intersection
      Rails.logger.debug "Bound repo ids: #{bound_ids.inspect}"
      Rails.logger.debug "Update repo ids: #{update_ids.inspect}"
      Rails.logger.debug "Repo ids to bind: #{bind_ids.inspect}"
      Rails.logger.debug "Repo ids to unbind: #{unbind_ids.inspect}"
      processed_ids = []; error_ids = []
      unbind_ids.each do |repoid|
        begin
          Pulp::Consumer.unbind(uuid, repoid)
          processed_ids << repoid
        rescue => e
          Rails.logger.error "Failed to unbind repo #{repoid}: #{e}, #{e.backtrace.join("\n")}"
          error_ids << repoid
        end
      end
      bind_ids.each do |repoid|
        begin
          Pulp::Consumer.bind(uuid, repoid)
          processed_ids << repoid
        rescue => e
          Rails.logger.error "Failed to bind repo #{repoid}: #{e}, #{e.backtrace.join("\n")}"
          error_ids << repoid
        end
      end
      [processed_ids, error_ids]
    rescue => e
      Rails.logger.error "Failed to enable repositories: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_pulp_consumer
      Rails.logger.debug "Deleting consumer in pulp: #{self.name}"
      Pulp::Consumer.destroy(self.uuid)
    rescue => e
      Rails.logger.error "Failed to delete pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def destroy_pulp_orchestration
      return true if self.is_a? Hypervisor
      pre_queue.create(:name => "delete pulp consumer: #{self.name}", :priority => 3, :action => [self, :del_pulp_consumer])
    end

    def set_pulp_consumer
      Rails.logger.debug "Creating a consumer in pulp: #{self.name}"
      return Pulp::Consumer.create(self.organization.cp_key, self.uuid, self.description)
    rescue => e
      Rails.logger.error "Failed to create pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end
    
    def update_pulp_consumer
      return true if @changed_attributes.empty?

      Rails.logger.debug "Updating consumer in pulp: #{@old.name}"
      Pulp::Consumer.update(self.organization.cp_key, self.uuid, self.description)
    rescue => e
      Rails.logger.error "Failed to update pulp consumer #{@old.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end
    
    def upload_package_profile profile
      Rails.logger.debug "Uploading package profile for consumer #{self.name}"
      Pulp::Consumer.upload_package_profile(self.uuid, profile)
    rescue => e
      Rails.logger.error "Failed to upload package profile to pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e  
    end

    def install_package packages
      Rails.logger.debug "Scheduling package install for consumer #{self.name}"
      pulp_task = Pulp::Consumer.install_packages(self.uuid, packages)
    rescue => e
      Rails.logger.error "Failed to schedule package install for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def uninstall_package packages
      Rails.logger.debug "Scheduling package uninstall for consumer #{self.name}"
      pulp_task = Pulp::Consumer.uninstall_packages(self.uuid, packages)
    rescue => e
      Rails.logger.error "Failed to schedule package uninstall for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def update_package packages
      Rails.logger.debug "Scheduling package update for consumer #{self.name}"
      pulp_task = Pulp::Consumer.update_packages(self.uuid, packages)
    rescue => e
      Rails.logger.error "Failed to schedule package update for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def install_package_group groups
      Rails.logger.debug "Scheduling package group install for consumer #{self.name}"
      pulp_task = Pulp::Consumer.install_package_groups(self.uuid, groups)
    rescue => e
      Rails.logger.error "Failed to schedule package group install for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def uninstall_package_group groups
      Rails.logger.debug "Scheduling package group uninstall for consumer #{self.name}"
      pulp_task = Pulp::Consumer.uninstall_package_groups(self.uuid, groups)
    rescue => e
      Rails.logger.error "Failed to schedule package group uninstall for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def install_consumer_errata errata_ids
      Rails.logger.debug "Scheduling errata install for consumer #{self.name}"
      pulp_task = Pulp::Consumer.install_errata(self.uuid, errata_ids)
    rescue => e
      Rails.logger.error "Failed to schedule errata install for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def save_pulp_orchestration
      return true if self.is_a? Hypervisor
      case orchestration_for
        when :create
          pre_queue.create(:name => "create pulp consumer: #{self.name}", :priority => 3, :action => [self, :set_pulp_consumer])
        when :update
          pre_queue.create(:name => "update pulp consumer: #{self.name}", :priority => 3, :action => [self, :update_pulp_consumer])
      end
    end

  end
end
