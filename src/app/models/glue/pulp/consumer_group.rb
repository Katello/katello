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
      lazy_accessor  :description, :consumerids, :initializer => lambda { Pulp::ConsumerGroup.find(pulp_id) }

      before_save :save_consumer_group_orch
      before_destroy :destroy_consumer_group_orch
    end
  end

  module InstanceMethods

    def set_pulp_consumer_group
      Rails.logger.debug "creating pulp consumer group '#{self.pulp_id}'"
      Pulp::ConsumerGroup.create :id => self.pulp_id, :description=>self.description, :consumerids=>[]
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


    def destroy_consumer_group_orch
      pre_queue.create(:name => "delete pulp consumer group: #{self.pulp_id}", :priority => 3, :action => [self, :del_pulp_consumer_group])
    end

    def save_consumer_group_orch
      case orchestration_for
        when :create
          pre_queue.create(:name => "create pulp consumer group: #{self.pulp_id}", :priority => 3, :action => [self, :set_pulp_consumer_group])
        when :update

      end
    end

  end
end
