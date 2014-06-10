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
      module Package
        class Update < Actions::EntryAction

          include Helpers::Presenter

          def plan(system, packages)
            Type! system, ::Katello::System

            action_subject(system, :packages => packages)
            plan_action(Pulp::Consumer::ContentUpdate,
                        consumer_uuid: system.uuid,
                        type:          'rpm',
                        args:          packages)
          end

          def humanized_name
            _("Update package")
          end

          def humanized_input
            [input[:packages].join(", ")] + super
          end

          def presenter
            Helpers::Presenter::Delegated.new(self, planned_actions(Pulp::Consumer::ContentUpdate))
          end
        end
      end
    end
  end
end
