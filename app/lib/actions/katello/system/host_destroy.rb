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
      class HostDestroy < Actions::EntryAction
        def plan(host)
          action_subject(host)
          sequence do
            if host.content_host
              plan_action(Katello::System::Destroy, host.content_host)
            end
            plan_self(:host_id => host.id)
          end
        end

        def humanized_name
          _("Destroy Host")
        end

        def finalize
          host = Host.find(input[:host_id])
          unless host.reload.destroy
            fail host.errors.full_messages.join('; ')
          end
        end
      end
    end
  end
end
