# Copyright 2014 Red Hat, Inc.
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
  module Concerns
    module HostManagedExtensions
      extend ActiveSupport::Concern

      included do
        alias_method_chain :validate_media?, :capsule

        has_one :content_host, :class_name => "Katello::System", :foreign_key => :host_id,
                :dependent => :destroy, :inverse_of => :foreman_host
        belongs_to :content_source, :class_name => "::SmartProxy", :foreign_key => :content_source_id, :inverse_of => :hosts
        scoped_search :in => :content_source, :on => :name, :complete_value => true, :rename => :content_source

        has_one :system_host_join, :class_name => "Katello::SystemHostJoin", :dependent => :nullify, :foreign_key => :host_id
        has_one :content_view, :through => :system_host_join, :source => :content_view, :dependent => :nullify
        has_one :kt_environment, :through => :system_host_join, :source => :kt_environment, :dependent => :nullify
      end

      def validate_media_with_capsule?
        content_source_id.blank? && validate_media_without_capsule?
      end

      def content_view_id
        build_system_host_join.content_view_id if new_record?
        system_host_join.try(:content_view_id)
      end
      def content_view_id=(int)
        return false unless (int)
        if (cv = Katello::ContentView.find_by_id(int))
          self.content_view = cv
        else
          # nullify didn't work in association
          self.system_host_join.update_attribute(:content_view_id, nil) if self.system_host_join
        end
      end

      def kt_environment_id
        build_system_host_join.kt_environment_id if new_record?
        system_host_join.try(:kt_environment_id)
      end
      def kt_environment_id=(int)
        if (env = Katello::KTEnvironment.find_by_id(int))
          self.kt_environment = env
        else
          # nullify didn't work in association
          self.system_host_join.update_attribute(:kt_environment_id, nil) if self.system_host_join
        end
      end

    end
  end
end

class ::Host::Managed::Jail < Safemode::Jail
  allow :content_source
end
