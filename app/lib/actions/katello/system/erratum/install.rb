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
      module Erratum
        class Install < Actions::EntryAction
          include Helpers::Presenter

          def plan(system, errata_ids)
            Type! system, ::Katello::System

            action_subject(system, :errata => errata_ids)
            plan_action(Pulp::Consumer::ContentInstall,
                        consumer_uuid: system.uuid,
                        type:          'erratum',
                        args:          errata_ids)
          end

          def humanized_name
            _("Install erratum")
          end

          def humanized_input
            [input[:errata].join(", ")] + super
          end

          def resource_locks
            :link
          end

          def presenter
            Helpers::Presenter::Delegated.new(self, planned_actions(Pulp::Consumer::ContentInstall))
          end
        end
      end
    end
  end
end
