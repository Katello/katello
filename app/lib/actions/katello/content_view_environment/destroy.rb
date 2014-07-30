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
      class Destroy < Actions::Base

        def plan(cv_env)
          content_view = cv_env.content_view
          environment = cv_env.environment
          content_view.check_remove_from_environment!(environment)

          sequence do
            concurrence do
              content_view.repos(environment).each do |repo|
                # no need to update the content view environment since it's
                # getting destroyed so skip_environment_update
                plan_action(Repository::Destroy, repo, skip_environment_update: true)
              end

              if puppet_env = content_view.puppet_env(environment)
                plan_action(ContentViewPuppetEnvironment::Destroy, puppet_env)
              end
            end
            plan_action(Candlepin::Environment::Destroy, cp_id: cv_env.cp_id)

            cv_env.reload
            cv_env.destroy
          end
        end

      end
    end
  end
end
