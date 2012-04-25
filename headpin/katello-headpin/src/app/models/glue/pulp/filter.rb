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
      Rails.logger.debug "creating pulp filter '#{self.pulp_id}'"
      Pulp::Filter.create :id => self.pulp_id, :type => "blacklist", :package_list => self.package_list, :description => self.description
    rescue => e
      Rails.logger.error "Failed to create pulp filter #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_pulp_filter
      Rails.logger.debug "deleting pulp filter '#{self.pulp_id}'"
      Pulp::Filter.destroy self.pulp_id
    rescue => e
      Rails.logger.error "Failed to delete pulp filter #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def set_packages package_list
      Rails.logger.debug "adding packages to pulp filter '#{self.pulp_id}'"
      Pulp::Filter.add_packages pulp_id, package_list
    rescue => e
      Rails.logger.error "Failed to add packages to pulp filter #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_packages package_list
      Rails.logger.debug "removing packages to pulp filter '#{self.pulp_id}'"
      Pulp::Filter.remove_packages pulp_id, package_list
    rescue => e
      Rails.logger.error "Failed to remove packages from pulp filter #{self.pulp_id}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def destroy_filter_orchestration
      pre_queue.create(:name => "delete pulp filter: #{self.pulp_id}", :priority => 3, :action => [self, :del_pulp_filter])
    end

    def save_filter_orchestration
      case orchestration_for
        when :create
          pre_queue.create(:name => "create pulp filter: #{self.pulp_id}", :priority => 3, :action => [self, :set_pulp_filter])
        when :update
          if package_list_changed?

            old_packages = package_list_change[0].nil? ? [] : package_list_change[0]
            new_packages = package_list_change[1]

            added_filters = (new_packages - old_packages).uniq
            removed_filters = old_packages - new_packages

            pre_queue.create(:name => "adding packages to filter: #{self.pulp_id}", :priority => 3, :action => [self, :set_packages, added_filters]) unless added_filters.empty?
            pre_queue.create(:name => "removing packages from filter: #{self.pulp_id}", :priority => 4, :action => [self, :del_packages, removed_filters]) unless removed_filters.empty?
          end
      end
    end

    def as_json(options)
      options.nil? ?
          super(:methods => [:description, :package_list]) :
          super(options.merge(:methods => [:description, :package_list]) {|k, v1, v2| [v1, v2].flatten })
    end
  end
end
