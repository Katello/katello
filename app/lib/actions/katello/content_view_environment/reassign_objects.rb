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
    module ContentViewEnvironment
      class ReassignObjects < Actions::Base
        def plan(content_view_environment, options)
          concurrence do
            content_view_environment.systems.each do |system|
              plan_action(System::Reassign, system, options[:system_content_view_id], options[:system_environment_id])
            end

            content_view_environment.activation_keys.each do |key|
              plan_action(ActivationKey::Reassign, key, options[:key_content_view_id], options[:key_environment_id])
            end
          end
        end
      end
    end
  end
end
