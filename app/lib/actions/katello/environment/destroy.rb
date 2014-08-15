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
      class Destroy < Actions::EntryAction
        def plan(env)
          sequence do
            env.disable_auto_reindex!
            action_subject(env)

            concurrence do
              env.content_view_environments.each do |cve|
                plan_action(ContentView::Remove, cve.content_view, :content_view_environments => [cve])
              end
            end

            env.reload.destroy!
            plan_action(ElasticSearch::Reindex, env)
          end
        end

        def humanized_name
          _("Delete Lifecycle Environment")
        end
      end
    end
  end
end
