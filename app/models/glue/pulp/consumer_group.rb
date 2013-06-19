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


module Glue::Pulp::ConsumerGroup

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :include, LazyAccessor

    base.class_eval do
      lazy_accessor  :consumer_ids, :initializer => lambda { |s| Runcible::Extensions::ConsumerGroup.retrieve(pulp_id) }

      before_save     :save_consumer_group_orch
      before_destroy  :destroy_consumer_group_orch

      add_system_hook     :add_consumer
      remove_system_hook  :remove_consumer
    end
  end

  module InstanceMethods

    def set_pulp_consumer_group
      consumer_ids = self.systems.collect { |system| system.uuid }
      Rails.logger.debug "creating pulp consumer group '#{self.pulp_id}'"
      Runcible::Extensions::ConsumerGroup.create(self.pulp_id, :description=>self.description, :consumer_ids=>(consumer_ids || []))
    rescue => e
      Rails.logger.error "Failed to create pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_pulp_consumer_group
      Rails.logger.debug "deleting pulp consumer group '#{self.pulp_id}'"
      Runcible::Extensions::ConsumerGroup.delete(self.pulp_id)
    rescue => e
      Rails.logger.error "Failed to delete pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def add_consumer(system)
      add_consumers([system.uuid])
    end

    def add_consumers(id_list)
      Rails.logger.debug "adding consumers to pulp consumer group '#{self.pulp_id}'"
      Runcible::Extensions::ConsumerGroup.add_consumers_by_id(pulp_id, id_list)
    rescue => e
      Rails.logger.error "Failed to add consumers to pulp consumer group  #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def remove_consumer(system)
      remove_consumers([system.uuid])
    end

    def remove_consumers(id_list)
      Rails.logger.debug "removing consumers from pulp consumer group '#{self.pulp_id}'"
      Runcible::Extensions::ConsumerGroup.remove_consumers_by_id(pulp_id, id_list)
    rescue => e
      Rails.logger.error "Failed to remove consumers from consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def install_package(packages)
      Rails.logger.debug "Scheduling package install for consumer group #{self.pulp_id}"

      pulp_task = Runcible::Extensions::ConsumerGroup.install_content(self.pulp_id,
                                                                      'rpm',
                                                                      packages,
                                                                      {'importkeys' => true})
    rescue => e
      Rails.logger.error "Failed to schedule package install for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def uninstall_package(packages)
      Rails.logger.debug "Scheduling package uninstall for consumer group #{self.pulp_id}"

      pulp_task = Runcible::Extensions::ConsumerGroup.uninstall_content(self.pulp_id,
                                                                        'rpm',
                                                                        packages)
    rescue => e
      Rails.logger.error "Failed to schedule package uninstall for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def update_package(packages)
      Rails.logger.debug "Scheduling package update for consumer group #{self.pulp_id}"

      pulp_task = Runcible::Extensions::ConsumerGroup.update_content(self.pulp_id,
                                                                     'rpm',
                                                                     packages,
                                                                     {'importkeys' => true})
    rescue => e
      Rails.logger.error "Failed to schedule package update for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def install_package_group(groups)
      Rails.logger.debug "Scheduling package group install for consumer group #{self.pulp_id}"

      pulp_task = Runcible::Extensions::ConsumerGroup.install_content(self.pulp_id,
                                                                      'package_group',
                                                                      groups,
                                                                      {'importkeys' => true})
    rescue => e
      Rails.logger.error "Failed to schedule package group install for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def uninstall_package_group(groups)
      Rails.logger.debug "Scheduling package group uninstall for consumer group #{self.pulp_id}"

      pulp_task = Runcible::Extensions::ConsumerGroup.uninstall_content(self.pulp_id,
                                                                        'package_group',
                                                                        groups)
    rescue => e
      Rails.logger.error "Failed to schedule package group uninstall for pulp consumer group #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def install_consumer_errata(errata_ids)
      Rails.logger.debug "Scheduling errata install for consumer group #{self.pulp_id}"

      pulp_task = Runcible::Extensions::ConsumerGroup.install_content(self.pulp_id,
                                                                      'erratum',
                                                                      errata_ids,
                                                                      {'importkeys' => true})
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
          if consumer_ids_changed?
            old_consumers = consumer_ids_change[0].nil? ? [] : consumer_ids_change[0]
            new_consumers = consumer_ids_change[1]

            added_consumers = (new_consumers - old_consumers).uniq
            removed_consumers = old_consumers - new_consumers

            pre_queue.create(:name => "adding consumers to group: #{self.pulp_id}", :priority => 3, :action => [self, :add_consumers, added_consumers]) unless added_consumers.empty?
            pre_queue.create(:name => "removing consumers from group: #{self.pulp_id}", :priority => 4, :action => [self, :remove_consumers, removed_consumers]) unless removed_consumers.empty?
          end
      end
    end

  end
end
