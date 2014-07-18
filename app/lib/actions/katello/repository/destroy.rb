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
    module Repository
      class Destroy < Actions::EntryAction

        # options:
        #   skip_environment_update - defaults to false. skips updating the CP environment
        #
        def plan(repository, options = {})
          skip_environment_update = options.fetch(:skip_environment_update, false)
          action_subject(repository)
          plan_action(ContentViewPuppetModule::Destroy, repository) if repository.puppet?
          plan_action(Pulp::Repository::Destroy, pulp_id: repository.pulp_id)
          plan_action(Product::ContentDestroy, repository)
          plan_action(ElasticSearch::Repository::Destroy, pulp_id: repository.pulp_id)

          if !skip_environment_update && ::Katello.config.use_cp
            plan_action(ContentView::UpdateEnvironment, repository.content_view, repository.environment)
          end

          repository.destroy!
        end

        def humanized_name
          _("Delete")
        end
      end
    end
  end
end
