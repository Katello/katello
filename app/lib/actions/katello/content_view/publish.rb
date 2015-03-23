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
        def plan(content_view, description = "")
          action_subject(content_view)
          content_view.check_ready_to_publish!
          version = content_view.create_new_version(description)
          library = content_view.organization.library

          history = ::Katello::ContentViewHistory.create!(:content_view_version => version, :user => ::User.current.login,
                                                          :status => ::Katello::ContentViewHistory::IN_PROGRESS, :task => self.task)

          sequence do
            plan_action(ContentView::AddToEnvironment, version, library)
            concurrence do
              content_view.repositories_to_publish.each do |repository|
                sequence do
                  clone_to_version = plan_action(Repository::CloneToVersion, repository, version)
                  plan_action(Repository::CloneToEnvironment, clone_to_version.new_repository, library)
                end
              end

              sequence do
                plan_action(ContentViewPuppetEnvironment::CreateForVersion, version)
                plan_action(ContentViewPuppetEnvironment::Clone, version, :environment => library)
              end

              repos_to_delete(content_view).each do |repo|
                plan_action(Repository::Destroy, repo, :planned_destroy => true)
              end
            end

            plan_action(ContentView::UpdateEnvironment, content_view, library)
            plan_action(Katello::Foreman::ContentUpdate, library, content_view)
            plan_action(ContentView::ErrataMail, content_view, library)
            plan_self(history_id: history.id, content_view_id: content_view.id,
                      environment_id: library.id, user_id: ::User.current.id)
          end
        end

        def humanized_name
          _("Publish")
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

        def repos_to_delete(content_view)
          if content_view.composite?
            library_instances = content_view.repositories_to_publish.map(&:library_instance_id)
          else
            library_instances = content_view.repositories_to_publish.map(&:id)
          end
          content_view.repos(content_view.organization.library).find_all do |repo|
            !library_instances.include?(repo.library_instance_id)
          end
        end
      end
    end
  end
end
