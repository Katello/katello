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
      class UpdateEnvironment < Actions::Base
        def plan(content_view, environment, new_content_id = nil)
          view_env = content_view.content_view_environment(environment)
          content_ids = content_view.repos(environment).map(&:content_id).uniq.compact
          # in case we create new custom repository that doesn't have the
          # content_id set yet in the plan phase, we allow to pass it as
          # additional argument
          content_ids << new_content_id if new_content_id && !content_ids.include?(new_content_id)
          plan_action(Candlepin::Environment::SetContent,
                      cp_environment_id: view_env.cp_id,
                      content_ids:       content_ids)

          plan_self(:environment_id => environment.id)
        end
      end
    end
  end
end
