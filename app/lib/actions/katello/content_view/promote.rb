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
        def plan(version, environment, is_force = false)
          action_subject(version.content_view)
          version.check_ready_to_promote!

          fail ::Katello::HttpErrors::BadRequest, _("Cannot promote environment out of sequence. Use force to bypass restriction.") if !is_force && !version.promotable?(environment)

          history = ::Katello::ContentViewHistory.create!(:content_view_version => version, :user => ::User.current.login,
                                                          :environment => environment, :task => self.task,
                                                          :status => ::Katello::ContentViewHistory::IN_PROGRESS)
          sequence do
            plan_action(ContentView::AddToEnvironment, version, environment)
            concurrence do
              version.archived_repos.non_puppet.each do |repository|
                sequence do
                  plan_action(Repository::CloneToEnvironment, repository, environment)
                end
              end

              plan_action(ContentViewPuppetEnvironment::Clone, version, :environment => environment)

              repos_to_delete(version, environment).each do |repo|
                plan_action(Repository::Destroy, repo)
              end
            end

            plan_action(ContentView::UpdateEnvironment, version.content_view, environment)
            plan_action(ContentView::ErrataMail, version.content_view, environment)
            plan_self(history_id: history.id, environment_id: environment.id, user_id: ::User.current.id,
                      environment_name: environment.name, content_view_id: version.content_view.id)
          end
        end

        def humanized_name
          _("Promotion")
        end

        def run
          ::User.current = ::User.find(input[:user_id])
          ForemanTasks.async_task(ContentView::NodeMetadataGenerate,
                                  ::Katello::ContentView.find(input[:content_view_id]),
                                  ::Katello::KTEnvironment.find(input[:environment_id]))
        ensure
          ::User.current = nil
        end

        def finalize
          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!
        end

        private

        def repos_to_delete(version, environment)
          archived_library_instance_ids = version.archived_repos.collect { |archived| archived.library_instance_id }
          version.content_view.repos(environment).find_all do |repo|
            !archived_library_instance_ids.include?(repo.library_instance_id)
          end
        end
      end
    end
  end
end
