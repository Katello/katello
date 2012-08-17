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

module Glue::Pulp::User
  def self.included(base)
    base.send :include, InstanceMethods
    base.send :include, LazyAccessor
    base.class_eval do
      lazy_accessor :login, :name, :initializer => lambda { Resources::Pulp::User.find(self.username) }

      before_save :save_pulp_orchestration
      before_destroy :destroy_pulp_orchestration
    end
  end

  module InstanceMethods

    def initialize(attrs = nil)
      unless attrs.nil?
        attrs = attrs.reject do |k, v|
          !attributes_from_column_definition.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
        end
      end

      super(attrs)
    end

    def set_pulp_user
      Resources::Pulp::User.create(:login => self.username, :name => self.username, :password => Password.generate_random_string(16))
    rescue RestClient::ExceptionWithResponse => e
      if e.http_code == 409
        Rails.logger.info "pulp user #{self.username}: already exists. continuing"
        true #assume everything is ok unless there was an exception thrown
      else
        Rails.logger.error "Failed to create pulp user #{self.username}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end
    rescue => e
      Rails.logger.error "Failed to create pulp user #{self.username}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def set_super_user_role
      #TODO add this back once role support actually works
      #Resources::Pulp::Roles.add "super-users", self.username
      true #assume everything is ok unless there was an exception thrown
    end

    def del_pulp_user
      Resources::Pulp::User.destroy(self.username)
    rescue => e
      Rails.logger.error "Failed to delete pulp user #{self.username}: #{e}, #{e.backtrace.join("\n")}"
      raise e
    end

    def del_super_admin_role
      Resources::Pulp::Roles.remove "super-users", self.username
      true #assume everything is ok unless there was an exception thrown
    end

    def save_pulp_orchestration
      case self.orchestration_for
        when :create
          pre_queue.create(:name => "create pulp user: #{self.username}", :priority => 3, :action => [self, :set_pulp_user])
          pre_queue.create(:name => "add 'super-user' to: #{self.username}", :priority => 4, :action => [self, :set_super_user_role])
      end
    end

    def destroy_pulp_orchestration
      pre_queue.create(:name => "remove 'super-user' from: #{self.username}", :priority => 3, :action => [self, :del_super_admin_role])
      pre_queue.create(:name => "delete pulp user: #{self.username}", :priority => 4, :action => [self, :del_pulp_user])
    end
  end
end
