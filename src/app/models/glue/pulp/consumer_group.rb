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

require "resources/pulp"

module Glue::Pulp::ConsumerGroup

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :include, LazyAccessor

    base.class_eval do
      lazy_accessor  :consumerids, :initializer => lambda { Pulp::ConsumerGroup.find(pulp_id) }

      before_save :save_consumer_group_orch
      before_destroy :destroy_consumer_group_orch
    end
  end

  module InstanceMethods

    def set_pulp_consumer_group
      Rails.logger.debug "creating pulp consumer group '#{self.pulp_id}'"
      Pulp::ConsumerGroup.create :id => self.pulp_id, :description=>self.description, :consumerids=>(consumerids || [])
    rescue => e
      Rails.logger.error "Failed to create pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_pulp_consumer_group
      Rails.logger.debug "deleting pulp consumer group '#{self.pulp_id}'"
      Pulp::ConsumerGroup.destroy self.pulp_id
    rescue => e
      Rails.logger.error "Failed to delete pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def add_consumers id_list
      Rails.logger.debug "adding consumers to pulp consumer group '#{self.pulp_id}'"
      id_list.each{|consumer|
        Pulp::ConsumerGroup.add_consumer(pulp_id, consumer)
      }
    rescue => e
      Rails.logger.error "Failed to add consumers to pulp consumer group  #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_consumers id_list
      Rails.logger.debug "removing consumers from pulp consumer group '#{self.pulp_id}'"
      id_list.each{|consumer|
        Pulp::ConsumerGroup.delete_consumer(pulp_id, consumer)
      }
    rescue => e
      Rails.logger.error "Failed to remove consumers from consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def install_package packages
      Rails.logger.debug "Scheduling package install for consumer group #{self.pulp_id}"
      # initiate the action and return the response... a successful response will include a job containing 1 or more tasks
      response = Pulp::ConsumerGroup.install_packages(self.pulp_id, packages)
    rescue => e
      Rails.logger.error "Failed to schedule package install for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def uninstall_package packages
      Rails.logger.debug "Scheduling package uninstall for consumer group #{self.pulp_id}"
      # initiate the action and return the response... a successful response will include a job containing 1 or more tasks
      response = Pulp::ConsumerGroup.uninstall_packages(self.pulp_id, packages)
    rescue => e
      Rails.logger.error "Failed to schedule package uninstall for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def update_package packages
      Rails.logger.debug "Scheduling package update for consumer #{self.name}"
      # initiate the action and return the response... a successful response will include a job containing 1 or more tasks
      response = Pulp::ConsumerGroup.update_packages(self.pulp_id, packages)
    rescue => e
      Rails.logger.error "Failed to schedule package update for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def install_package_group groups
      Rails.logger.debug "Scheduling package group install for consumer group #{self.pulp_id}"
      # initiate the action and return the response... a successful response will include a job containing 1 or more tasks
      response = Pulp::ConsumerGroup.install_package_groups(self.pulp_id, groups)
    rescue => e
      Rails.logger.error "Failed to schedule package group install for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def uninstall_package_group groups
      Rails.logger.debug "Scheduling package group uninstall for consumer group #{self.pulp_id}"
      # initiate the action and return the response... a successful response will include a job containing 1 or more tasks
      response = Pulp::ConsumerGroup.uninstall_package_groups(self.pulp_id, groups)
    rescue => e
      Rails.logger.error "Failed to schedule package group uninstall for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def install_consumer_errata errata_ids
      Rails.logger.debug "Scheduling errata install for consumer group #{self.pulp_id}"
      # initiate the action and return the response... a successful response will include a job containing 1 or more tasks
      response = Pulp::ConsumerGroup.install_errata(self.pulp_id, errata_ids)
    rescue => e
      Rails.logger.error "Failed to schedule errata install for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def destroy_consumer_group_orch
      pre_queue.create(:name => "delete pulp consumer group: #{self.pulp_id}", :priority => 3, :action => [self, :del_pulp_consumer_group])
    end

    def save_consumer_group_orch
      case orchestration_for
        when :create
          pre_queue.create(:name => "create pulp consumer group: #{self.pulp_id}", :priority => 3, :action => [self, :set_pulp_consumer_group])
        when :update
          if consumerids_changed?
            old_consumers = consumerids_change[0].nil? ? [] : consumerids_change[0]
            new_consumers = consumerids_change[1]

            added_consumers = (new_consumers - old_consumers).uniq
            removed_consumers = old_consumers - new_consumers
            
            pre_queue.create(:name => "adding consumers to group: #{self.pulp_id}", :priority => 3, :action => [self, :add_consumers, added_consumers]) unless added_consumers.empty?
            pre_queue.create(:name => "removing consumers from group: #{self.pulp_id}", :priority => 4, :action => [self, :del_consumers, removed_consumers]) unless removed_consumers.empty?
          end
      end
    end

  end
end
