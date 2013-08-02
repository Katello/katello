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


module Katello
  module Glue::Pulp::User
    def self.included(base)
      if (base.method_defined?(:remote_id))
        base.send :include, InstanceMethods
        base.send :include, LazyAccessor
        base.class_eval do
          # ENGINIFY: Removed lazy retrieval of login since it isn't used and clashes with Foreman user
          lazy_accessor :name, :initializer => lambda {|s| Runcible::Resources::User.retrieve(self.remote_id)}
          before_save :save_pulp_orchestration
          before_destroy :destroy_pulp_orchestration
        end
      end
    end

    module InstanceMethods

      def initialize(attrs = nil, options={})
        attrs = prune_pulp_only_attributes(attrs)
        super
      end

      def prune_pulp_only_attributes(attrs)
        unless attrs.nil?
          attrs = attrs.reject do |k, v|
            !self.class.column_defaults.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
          end
        end

        return attrs
      end

      def set_pulp_user
        Runcible::Resources::User.create(self.remote_id, {:name => self.remote_id, :password => Password.generate_random_string(16)})
      rescue RestClient::ExceptionWithResponse => e
        if e.http_code == 409
          Rails.logger.info "pulp user #{self.remote_id}: already exists. continuing"
          true #assume everything is ok unless there was an exception thrown
        else
          Rails.logger.error "Failed to create pulp user #{self.remote_id}: #{e}, #{e.backtrace.join("\n")}"
          raise e
        end
      rescue => e
        Rails.logger.error "Failed to create pulp user #{self.remote_id}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end

      def set_super_user_role
        Runcible::Resources::Role.add "super-users", self.remote_id
        true #assume everything is ok unless there was an exception thrown
      end

      def del_pulp_user
        Runcible::Resources::User.delete(self.remote_id)
      rescue => e
        Rails.logger.error "Failed to delete pulp user #{self.remote_id}: #{e}, #{e.backtrace.join("\n")}"
        raise e
      end

      def del_super_admin_role
        Runcible::Resources::Role.remove("super-users", self.remote_id)
        true #assume everything is ok unless there was an exception thrown
      end

      def save_pulp_orchestration
        case self.orchestration_for
          when :create
            pre_queue.create(:name => "create pulp user: #{self.remote_id}", :priority => 3, :action => [self, :set_pulp_user])
            pre_queue.create(:name => "add 'super-user' to: #{self.remote_id}", :priority => 4, :action => [self, :set_super_user_role])
        end
      end

      def destroy_pulp_orchestration
        pre_queue.create(:name => "remove 'super-user' from: #{self.remote_id}", :priority => 3, :action => [self, :del_super_admin_role])
        pre_queue.create(:name => "delete pulp user: #{self.remote_id}", :priority => 4, :action => [self, :del_pulp_user])
      end
    end

  end
end
