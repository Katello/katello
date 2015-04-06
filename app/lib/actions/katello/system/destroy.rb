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
      class Destroy < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(system, options = {})
          skip_candlepin = options.fetch(:skip_candlepin, false)
          skip_pulp = system.hypervisor?
          action_subject(system)

          concurrence do
            plan_action(Candlepin::Consumer::Destroy, uuid: system.uuid) unless skip_candlepin
            plan_action(Pulp::Consumer::Destroy, uuid: system.uuid) unless skip_pulp
          end

          plan_self(:system_id => system.id)
        end

        def finalize
          system = ::Katello::System.find(input[:system_id])
          system.destroy!
        end

        def humanized_name
          _("Destroy Content Host")
        end
      end
    end
  end
end
