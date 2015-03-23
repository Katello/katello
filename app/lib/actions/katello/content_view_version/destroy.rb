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
        def plan(version, options = {})
          version.check_ready_to_destroy! unless options[:skip_environment_check]

          sequence do
            concurrence do
              version.archived_repos.each do |repo|
                repo_options = options.clone
                repo_options[:planned_destroy] = true
                plan_action(Repository::Destroy, repo, repo_options)
              end
              plan_action(ContentViewPuppetEnvironment::Destroy, version.archive_puppet_environment) unless version.default?
            end
          end

          plan_self(:id => version.id)
        end

        def finalize
          version = ::Katello::ContentViewVersion.find(input[:id])
          version.destroy!
        end
      end
    end
  end
end
