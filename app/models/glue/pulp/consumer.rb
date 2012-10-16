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

module Glue::Pulp::Consumer
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :include, LazyAccessor
    base.class_eval do
      before_save :save_pulp_orchestration
      before_destroy :destroy_pulp_orchestration
      after_rollback :rollback_on_pulp_create, :on => :create

      lazy_accessor :pulp_facts, :initializer => lambda { Runcible::Extensions::Consumer.retrieve(uuid) }
      lazy_accessor :package_profile, :initializer => lambda { Runcible::Extensions::Consumer.profile(uuid, 'rpm') }
      lazy_accessor :simple_packages, :initializer => lambda { Runcible::Extensions::Consumer.profile(uuid, 'rpm')["profile"].
                                                              collect{|package| Glue::Pulp::SimplePackage.new(package)} }
      lazy_accessor :errata, :initializer => lambda { Resources::Pulp::Consumer.errata(uuid).
                                                              collect{|errata| Errata.new(errata)} }
      lazy_accessor :repoids, :initializer => lambda { Runcible::Extensions::Consumer.repos(uuid).
                                                              collect{|repo| repo["repo_id"]} }
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
          Runcible::Extensions::Consumer.unbind_all(uuid, repoid)
          processed_ids << repoid
        rescue => e
          Rails.logger.error "Failed to unbind repo #{repoid}: #{e}, #{e.backtrace.join("\n")}"
          error_ids << repoid
        end
      end
      bind_ids.each do |repoid|
        begin
          Runcible::Extensions::Consumer.bind_all(uuid, repoid)
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
      Runcible::Extensions::Consumer.delete(self.uuid)
    rescue => e
      Rails.logger.error "Failed to delete pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def destroy_pulp_orchestration
      return true if self.is_a? Hypervisor
      pre_queue.create(:name => "delete pulp consumer: #{self.name}", :priority => 3, :action => [self, :del_pulp_consumer])
    end

    # A rollback occurred while attempting to create the consumer; therefore, perform necessary cleanup.
    def rollback_on_pulp_create
      del_pulp_consumer
    end

    def set_pulp_consumer
      Rails.logger.debug "Creating a consumer in pulp: #{self.name}"
      return Runcible::Extensions::Consumer.create(self.uuid, {:display_name => self.name})
    rescue => e
      Rails.logger.error "Failed to create pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end
    
    def update_pulp_consumer
      return true if @changed_attributes.empty?

      Rails.logger.debug "Updating consumer in pulp: #{@old.name}"
      Runcible::Extensions::Consumer.update(self.uuid, {"delta" => {:display_name => self.name}})
    rescue => e
      Rails.logger.error "Failed to update pulp consumer #{@old.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end
    
    def upload_package_profile profile
      Rails.logger.debug "Uploading package profile for consumer #{self.name}"
      Runcible::Extensions::Consumer.upload_profile(self.uuid, 'rpm', profile)
    rescue => e
      Rails.logger.error "Failed to upload package profile to pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e  
    end

    def install_package packages
      Rails.logger.debug "Scheduling package install for consumer #{self.name}"
      pulp_task = Runcible::Extensions::Consumer.install(self.uuid, 'rpm', packages)
    rescue => e
      Rails.logger.error "Failed to schedule package install for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def uninstall_package packages
      Rails.logger.debug "Scheduling package uninstall for consumer #{self.name}"
      pulp_task = Runcible::Extensions::Consumer.uninstall(self.uuid, 'rpm', packages)
    rescue => e
      Rails.logger.error "Failed to schedule package uninstall for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def update_package packages
      Rails.logger.debug "Scheduling package update for consumer #{self.name}"
      pulp_task = Runcible::Extensions::Consumer.update(self.uuid, 'rpm', packages)
    rescue => e
      Rails.logger.error "Failed to schedule package update for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def install_package_group groups
      Rails.logger.debug "Scheduling package group install for consumer #{self.name}"
      pulp_task = Runcible::Extensions::Consumer.install(self.uuid, 'package_group', groups)
    rescue => e
      Rails.logger.error "Failed to schedule package group install for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def uninstall_package_group groups
      Rails.logger.debug "Scheduling package group uninstall for consumer #{self.name}"
      pulp_task = Runcible::Extensions::Consumer..uninstall(self.uuid, 'package_group', groups)
    rescue => e
      Rails.logger.error "Failed to schedule package group uninstall for pulp consumer #{self.name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def install_consumer_errata errata_ids
      Rails.logger.debug "Scheduling errata install for consumer #{self.name}"
      pulp_task = Runcible::Extensions::Consumer.install(self.uuid, 'erratum', errata_ids)
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
