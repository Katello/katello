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
    module Organization
      class AutoAttachSubscriptions < Actions::EntryAction

        def plan(organization)
          action_subject(organization)
          plan_action(Candlepin::Owner::AutoAttach, label: organization.label)
        end

        def humanized_name
          _("Auto-attach subscriptions")
        end

      end
    end
  end
end
