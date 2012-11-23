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
      before_save :save_foreman_orchestration
      before_destroy :destroy_foreman_orchestration

      after_save :foreman_consistency_check
    end
  end

  module ClassMethods
  end

  module InstanceMethods
    def foreman_environment
      return nil unless foreman_id
      @foreman_environment ||= ::Foreman::Environment.find! foreman_id
    end

    alias_method :foreman, :foreman_environment

    def save_foreman_orchestration
      return if foreman_orchestration_disabled?
      case orchestration_for
        when :create
          pre_queue.create :name   => "create foreman environment: #{name}", :priority => 3,
                           :action => [self, :create_foreman_environment]
      end
    end

    def destroy_foreman_orchestration
      return if foreman_orchestration_disabled?
      pre_queue.create(:name   => "destroy foreman environment: #{name}", :priority => 3,
                       :action => [self, :destroy_foreman_environment])
    end

    def create_foreman_environment
      foreman_environment = ::Foreman::Environment.new(:name => name)
      foreman_environment.save!
      self.foreman_environment = foreman_environment
    end

    def destroy_foreman_environment
      self.foreman_environment.destroy!
    end

    private

    def foreman_consistency_check
      raise 'environment has to have foreman_id' unless foreman_orchestration_disabled? || self.foreman_id
    end

    def foreman_environment=(foreman_environment)
      @foreman_environment = foreman_environment
      self.foreman_id = foreman_environment.try :id
    end
  end

  include Glue::ForemanOrchestrationDisablement 

end
