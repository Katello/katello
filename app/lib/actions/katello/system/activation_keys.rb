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

module Actions
  module Katello
    module System
      class ActivationKeys < Actions::Base
        def plan(system, activation_keys)
          activation_keys ||= []

          set_environment_and_content_view(system, activation_keys)
          set_system_groups(system, activation_keys)
          set_association(system, activation_keys)
        end

        def set_association(system, activation_keys)
          system.activation_keys = activation_keys
        end

        def set_environment_and_content_view(system, activation_keys)
          return if system.content_view

          activation_key = activation_keys.detect do |act_key|
            act_key.environment && act_key.content_view
          end
          if activation_key
            system.environment = activation_key.environment
            system.content_view = activation_key.content_view
          else
            fail _('At least one activation key must have a lifecycle environment and content view assigned to it')
          end
        end

        def set_system_groups(system, activation_keys)
          system_group_ids = activation_keys.flat_map(&:system_group_ids).compact.uniq

          system_group_ids.each do |system_group_id|
            system_group = ::Katello::SystemGroup.find(system_group_id)
            if system_group.max_systems >= 0 && system_group.systems.length >= system_group.max_systems
              fail _("System group '%{name}' exceeds maximum usage limit of '%{limit}'") %
                       {:limit => system_group.max_systems, :name => system_group.name}
            end
          end
          system.system_group_ids = system_group_ids
        end
      end
    end
  end
end
