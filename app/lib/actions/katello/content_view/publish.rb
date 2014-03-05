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
          library = content_view.organization.library

          sequence do
            concurrence do
              content_view.repositories.each do |repository|
                sequence do
                  clone_to_version = plan_action(Repository::CloneToVersion, repository, version)
                  plan_action(Repository::CloneToEnvironment, clone_to_version.new_repository, library)
                end
              end
              repos_to_delete(content_view).each do |repo|
                plan_action(Repository::Destroy, repo)
              end
            end

            plan_action(ContentView::UpdateEnvironment, content_view, library)
          end
        end

        def humanized_name
          _("Publish")
        end

        private

        def repos_to_delete(content_view)
          content_view.repos(content_view.organization.library).find_all do |repo|
            !content_view.repository_ids.include?(repo.library_instance_id)
          end
        end

      end
    end
  end
end
