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

          cv_env = ::Katello::ContentViewEnvironment.where(:content_view_id => content_view.id,
                                                        :environment_id => environment.id).first

          if cv_env.nil?
            fail _("Cannot remove content view from environment. Content view '%{view}' is not in lifecycle environment '%{env}'.") %
              {view: content_view.name, env: environment.name}
          end

          history = ::Katello::ContentViewHistory.create!(:content_view_version => cv_env.content_view_version,
                                                          :environment => environment,
                                                          :user => ::User.current.login,
                                                          :status => ::Katello::ContentViewHistory::IN_PROGRESS,
                                                          :task => self.task)

          plan_action(ContentViewEnvironment::Destroy, cv_env)
          plan_self(history_id: history.id)
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
