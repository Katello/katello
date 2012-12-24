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

module Glue::Foreman::Environment

  def self.included(base)
    base.send :include, InstanceMethods
    base.send :extend, ClassMethods
    base.class_eval do
      before_save :save_foreman_environment_orchestration
      before_destroy :destroy_foreman_environment_orchestration
    end
  end

  module ClassMethods
    def disable_foreman_orchestration!(value)
      raise ArgumentError unless [true, false].include? value
      @foreman_orchestration_disabled = value
    end

    def foreman_orchestration_disabled?
      !!@foreman_orchestration_disabled
    end
  end

  module InstanceMethods
    def foreman_environment
      return nil unless @foreman_environment or foreman_id
      @foreman_environment ||= ::Foreman::Environment.find! foreman_id
    end

    def save_foreman_environment_orchestration
      return if library?
      return if self.class.foreman_orchestration_disabled?
      case orchestration_for
        when :create
          pre_queue.create :name   => "create foreman environment: #{name}", :priority => 3,
                           :action => [self, :create_foreman_environment]
      end
    end

    def destroy_foreman_environment_orchestration
      return if library?
      return if self.class.foreman_orchestration_disabled?
      pre_queue.create(:name   => "destroy foreman environment: #{name}", :priority => 3,
                       :action => [self, :destroy_foreman_environment])
    end

    def create_foreman_environment
      @foreman_environment = ::Foreman::Environment.new(:name => name)
      foreman_environment.save!
      self.foreman_id = foreman_environment.id
    end

    def destroy_foreman_environment
      foreman_environment.destroy!
    end
  end
end