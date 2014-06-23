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
    module Environment
      class LibraryDestroy < Actions::EntryAction

        # this is what organization destroy uses to remove the org's library
        def plan(environment)
          environment.library_deletion = true
          plan_action(::Actions::Candlepin::Environment::Destroy, cp_id: environment.cp_id)
          environment.destroy!
        end
      end
    end
  end
end
