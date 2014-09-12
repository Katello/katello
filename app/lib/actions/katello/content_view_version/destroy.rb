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
    module ContentViewVersion
      class Destroy < Actions::Base
        def plan(version)
          version.check_ready_to_destroy!

          sequence do
            concurrence do
              version.repositories.each do |repo|
                plan_action(Repository::Destroy, repo, skip_environment_update: true)
              end

              version.content_view_puppet_environments.each do |puppet_env|
                plan_action(ContentViewPuppetEnvironment::Destroy, puppet_env)
              end
            end

            version.reload
            version.destroy
          end
        end
      end
    end
  end
end
