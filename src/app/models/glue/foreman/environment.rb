#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Glue::Foreman::Environment

  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      before_save :save_environment_orchestration
      before_destroy :destroy_environment_orchestration
    end
  end

  module InstanceMethods

    def set_environment
      new_environment = ForemanApi::Resources::Environment.new.create({:environment => {:name => name()}})
      self.foreman_id = new_environment[:id]
    rescue => e
      Rails.logger.error _("Failed to create foreman environment %s") % "#{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def update_environment
      ForemanApi::Resources::Environment.new.update({:environment => {:name => name()}})
    rescue => e
      Rails.logger.error _("Failed to update foreman environment %s") % "#{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_environment
      result = ForemanApi::Resources::Environment.new.destroy(self.foreman_id)
      result.code.to_i
    rescue => e
      Rails.logger.error _("Failed to delete foreman environment %s") % "#{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end
  end

  def save_environment_orchestration
    case self.orchestration_for
      when :create
        pre_queue.create(:name => "create environment in foreman: #{self.name}", :priority => 3, :action => [self, :set_environment])
    end
  end

  def destroy_environment_orchestration
    post_queue.create(:name => "destroy environment in foreman: #{self.name}", :priority => 4, :action => [self, :del_environment])
  end

end