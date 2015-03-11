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
        middleware.use ::Actions::Middleware::RemoteAction

        # options:
        #   skip_environment_update - defaults to false. skips updating the CP environment
        #   planned_destroy - default to false.  destroy the AR object in plan phase instead of finalize
        def plan(repository, options = {})
          planned_destroy = options.fetch(:planned_destroy, false)

          skip_environment_update = options.fetch(:organization_destroy, false)
          action_subject(repository)
          plan_action(ContentViewPuppetModule::Destroy, repository) if repository.puppet?
          plan_action(Pulp::Repository::Destroy, pulp_id: repository.pulp_id)
          plan_action(Product::ContentDestroy, repository) unless skip_environment_update
          plan_action(ElasticSearch::Repository::Destroy, pulp_id: repository.pulp_id)

          view_env = repository.content_view.content_view_environment(repository.environment)

          repository.destroy! if planned_destroy

          if !skip_environment_update && ::Katello.config.use_cp && view_env
            plan_action(ContentView::UpdateEnvironment, repository.content_view, repository.environment)
          end

          plan_self(:user_id => ::User.current.id, :planned_destroy => planned_destroy)
        end

        def finalize
          unless input[:planned_destroy]
            ::User.current = ::User.find(input[:user_id])
            repository = ::Katello::Repository.find(input[:repository][:id])
            repository.destroy!
          end
        ensure
          ::User.current = nil
        end

        def humanized_name
          _("Delete")
        end
      end
    end
  end
end
