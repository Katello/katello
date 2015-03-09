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
        middleware.use ::Actions::Middleware::RemoteAction

        input_format do
          param :id
          param :name
        end

        def plan(env, options = {})
          unless env.deletable?
            fail env.errors.full_messages.join(" ")
          end
          skip_repo_destroy = options.fetch(:skip_repo_destroy, false)
          organization_destroy = options.fetch(:organization_destroy, false)
          sequence do
            action_subject(env)

            concurrence do
              env.content_view_environments.each do |cve|
                plan_action(ContentView::Remove, cve.content_view, :content_view_environments => [cve], :skip_repo_destroy => skip_repo_destroy, :organization_destroy => organization_destroy)
              end
            end

            plan_self
          end
        end

        def humanized_name
          _("Delete Lifecycle Environment")
        end

        def humanized_input
          ["'#{input['kt_environment']['name']}'"] + super
        end

        def finalize
          environment = ::Katello::KTEnvironment.find(input['kt_environment']['id'])
          environment.destroy!
        end
      end
    end
  end
end
