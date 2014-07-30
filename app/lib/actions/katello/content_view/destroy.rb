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
      class Destroy < Actions::EntryAction

        middleware.use ::Actions::Middleware::RemoteAction

        def plan(content_view, options = {})
          action_subject(content_view)
          if options.fetch(:check_ready_to_destroy, true)
            content_view.check_ready_to_destroy!
          end

          sequence do
            concurrence do
              content_view.content_view_versions.each do |version|
                plan_action(ContentViewVersion::Destroy, version, options)
              end
            end

            plan_self
          end
        end

        def finalize
          content_view = ::Katello::ContentView.find(input[:content_view][:id])
          content_view.disable_auto_reindex!
          content_view.content_view_repositories.each(&:destroy)
          content_view.destroy!
        end

        def humanized_name
          _("Delete")
        end

      end
    end
  end
end
