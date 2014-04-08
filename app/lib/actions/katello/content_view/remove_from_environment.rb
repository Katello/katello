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
      class RemoveFromEnvironment < Actions::EntryAction

        def plan(content_view, environment)
          action_subject(content_view)
          content_view.check_remove_from_environment!(environment)

          cve = ::Katello::ContentViewEnvironment.where(:content_view_id => content_view.id,
                                                        :environment_id => environment.id).first

          history = ::Katello::ContentViewHistory.create!(:content_view_version => cve.content_view_version,
                                                          :environment => environment,
                                                          :user => ::User.current.login,
                                                          :status => ::Katello::ContentViewHistory::IN_PROGRESS,
                                                          :task => self.task)

          sequence do
            concurrence do
              content_view.repos(environment).each do |repo|
                plan_action(Repository::Destroy, repo)
              end

              if puppet_env = content_view.puppet_env(environment)
                plan_action(ContentViewPuppetEnvironment::Destroy, puppet_env)
              end
            end
            plan_action(Candlepin::Environment::Destroy, cp_id: cve.cp_id)

            cve.destroy
            plan_self(history_id: history.id)
          end
        end

        def finalize
          history = ::Katello::ContentViewHistory.find(input[:history_id])
          history.status = ::Katello::ContentViewHistory::SUCCESSFUL
          history.save!
        end

        def humanized_name
          _("Remove from Environment")
        end

      end
    end
  end
end
