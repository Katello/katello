# rubocop:disable AccessModifierIndentation
#
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
    module SmartProxyExtensions
      extend ActiveSupport::Concern

      included do
        before_create :associate_organizations
        before_create :associate_default_location
        before_create :associate_lifecycle_environments
        attr_accessible :lifecycle_environment_ids

        has_many :capsule_lifecycle_environments,
                 :class_name  => "Katello::CapsuleLifecycleEnvironment",
                 :foreign_key => :capsule_id,
                 :dependent   => :destroy,
                 :inverse_of => :capsule

        has_many :lifecycle_environments,
                 :class_name => "Katello::KTEnvironment",
                 :through    => :capsule_lifecycle_environments,
                 :source     => :lifecycle_environment

        has_many :hosts,      :class_name => "::Host::Managed", :foreign_key => :content_source_id,
                 :inverse_of => :content_source
        has_many :hostgroups, :class_name => "::Hostgroup",     :foreign_key => :content_source_id,
                 :inverse_of => :content_source
      end

      def default_capsule?
        server_fqdn = Facter.value(:fqdn) || SETTINGS[:fqdn]
        self.name == server_fqdn
      end

      def associate_organizations
        self.organizations = Organization.all if self.default_capsule?
      end

      def associate_default_location
        if self.default_capsule?
          default_location = Location.default_location
          if default_location && !self.locations.include?(default_location)
            self.locations << default_location
          end
        end
      end

      def associate_lifecycle_environments
        self.lifecycle_environments = Katello::KTEnvironment.all if self.default_capsule?
      end
    end
  end
end

class ::SmartProxy::Jail < Safemode::Jail
  allow :hostname
end
