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
    base.send(:include, InstanceMethods)

    base.class_eval do
      before_save :save_foreman_environment_orchestration
      before_destroy :destroy_foreman_environment_orchestration
    end
  end

  module InstanceMethods
    def set_foreman_environment
      new_environment = Foreman::Environment.create! :name => name
      self.foreman_id = new_environment.id
    end

    def del_foreman_environment
      result = Foreman::Environment.delete(foreman_id)
      result.code.to_i
    end
  end

  def save_foreman_environment_orchestration
    case self.orchestration_for
      when :create
        pre_queue.create(:name => "create environment in foreman: #{self.name}", :priority => 3, :action => [self, :set_foreman_environment])
    end
  end

  def destroy_foreman_environment_orchestration
    post_queue.create(:name => "destroy environment in foreman: #{self.name}", :priority => 4, :action => [self, :del_foreman_environment])
  end

end