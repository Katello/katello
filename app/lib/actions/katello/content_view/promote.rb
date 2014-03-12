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
      class Promote < Actions::EntryAction

        def plan(version, environment)
          action_subject(version.content_view)

          history = ::Katello::ContentViewHistory.create!(:content_view_version => version, :user => ::User.current.login,
                                                :environment => environment, :task => self.task,
                                               :status => ::Katello::ContentViewHistory::IN_PROGRESS)


          version.add_environment(environment)
          version.save!

          sequence do
            concurrence do

              version.archived_repos.non_puppet.each do |repository|
                sequence do
                  plan_action(Repository::CloneToEnvironment, repository, environment)
                end
              end
              repos_to_delete(version, environment).each do |repo|
                plan_action(Repository::Destroy, repo)
              end
              #TODO handle puppet content
            end

            plan_action(ContentView::UpdateEnvironment, version.content_view, environment)
            plan_self(history_id: history.id)
          end
        end

        def humanized_name
          _("Promotion")
        end

        def finalize
          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!
        end

        private

        def repos_to_delete(version, environment)
          version.content_view.repos(environment).find_all do |repo|
            !version.archived_repos.include?(repo.library_instance_id)
          end
        end

      end
    end
  end
end
