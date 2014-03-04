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
    module ContentView
      class UpdateEnvironment < Dynflow::Action

        def plan(content_view, environment)
          view_env = content_view.content_view_environment(environment)
          content_ids = content_view.repos(environment).select(&:enabled).
              map(&:content_id).uniq
          plan_action(Candlepin::Environment::SetContent,
                      cp_environment_id: view_env.cp_id,
                      content_ids:       content_ids)
        end

      end
    end
  end
end
