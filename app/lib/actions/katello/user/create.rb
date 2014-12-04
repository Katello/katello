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
    module User
      class Create < Actions::EntryAction
        def plan(user)
          action_subject user
          sequence do
            plan_action(Pulp::User::Create, remote_id: user.remote_id)
            plan_action(Pulp::Superuser::Add, remote_id: user.remote_id)
          end
        end
      end
    end
  end
end
