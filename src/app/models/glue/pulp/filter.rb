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

module Glue::Pulp::Filter

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :include, LazyAccessor

    base.class_eval do
      lazy_accessor :description, :package_list, :initializer => lambda { Pulp::Filter.find(pulp_id) }

      before_save :save_filter_orchestration
      before_destroy :destroy_filter_orchestration
    end
  end

  module InstanceMethods

    def set_pulp_filter
      Rails.logger.info "creating pulp filter '#{self.pulp_id}'"
      Pulp::Filter.create :id => self.pulp_id, :type => "blacklist", :package_list => self.package_list, :description => self.description
    rescue => e
      Rails.logger.error "Failed to create pulp filter #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_pulp_filter
      Rails.logger.info "deleting pulp filter '#{self.pulp_id}'"
      Pulp::Filter.destroy self.pulp_id
    rescue => e
      Rails.logger.error "Failed to delete pulp filter #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def update_pulp_filter
      return true unless package_list_changed?

      Rails.logger.info "updating pulp filter '#{self.pulp_id}'"
      old_content = package_list_change[0].nil? ? [] : package_list_change[0]
      new_content = package_list_change[1]

      added_filters = (new_content - old_content).uniq
      removed_filters = old_content - new_content

      Pulp::Filter.add_packages pulp_id, added_filters unless added_filters.empty?
      Pulp::Filter.remove_packages pulp_id, removed_filters unless removed_filters.empty?

      true
      # rollback ?
    rescue => e
      Rails.logger.error "Failed to delete pulp filter #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def destroy_filter_orchestration
      queue.create(:name => "delete pulp filter: #{self.pulp_id}", :priority => 3, :action => [self, :del_pulp_filter])
    end

    def save_filter_orchestration
      case orchestration_for
        when :create
          queue.create(:name => "create pulp filter: #{self.pulp_id}", :priority => 3, :action => [self, :set_pulp_filter])
        when :update
          queue.create(:name => "update pulp filter: #{self.pulp_id}", :priority => 3, :action => [self, :update_pulp_filter])
      end
    end

    def as_json(options)
      options.nil? ?
          super(:methods => [:description, :package_list]) :
          super(options.merge(:methods => [:description, :package_list]) {|k, v1, v2| [v1, v2].flatten })
    end

  end
end
