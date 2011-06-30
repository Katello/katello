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

require 'resources/candlepin'

module Glue::Candlepin::Owner

  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      before_save :save_owner_orchestration
      before_destroy :destroy_owner_orchestration

      validates :cp_key,
          :presence => true,
          :format => { :with => /^[\w-]*$/ }
    end
  end

  module InstanceMethods
    def set_owner
      Rails.logger.info "Creating an owner in candlepin: #{name}"
      Candlepin::Owner.create(cp_key, name)
    rescue => e
      Rails.logger.error "Failed to create candlepin owner #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_owner
      Rails.logger.info "Deleteing owner in candlepin: #{name}"
      Candlepin::Owner.destroy(cp_key)
    rescue => e
      Rails.logger.error "Failed to delete candlepin owner #{name}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def save_owner_orchestration
      case self.orchestration_for
        when :create
          queue.create(:name => "candlepin owner for organization: #{self.name}", :priority => 3, :action => [self, :set_owner])
      end
    end

    def destroy_owner_orchestration
      queue.create(:name => "candlepin owner for organization: #{self.name}", :priority => 3, :action => [self, :del_owner])
    end
  end

end
