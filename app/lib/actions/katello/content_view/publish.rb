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
      class Publish < Actions::EntryAction

        def plan(content_view)
          action_subject(content_view)
          unless content_view.ready_to_publish?
            fail _("Cannot publish view. Check for repository conflicts.")
          end
          version = content_view.create_new_version
          sequence do
            concurrence do
              content_view.repositories.each do |repo|
                sequence do
                  filters = content_view.filters.applicable(repo)
                  clone = repo.build_clone(content_view: content_view,
                                           version: version)
                  plan_action(Repository::Create, clone, true)
                  plan_action(Repository::CloneContent, repo, clone, filters)
                  plan_action(Repository::Promote, clone, clone.organization.library)
                end
              end

              # TODO: unpublish deleted repos
            end

            plan_action(ContentView::UpdateEnvironment,
                        content_view,
                        content_view.organization.library)
          end
        end

        def humanized_name
          _("Publish")
        end

      end
    end
  end
end
