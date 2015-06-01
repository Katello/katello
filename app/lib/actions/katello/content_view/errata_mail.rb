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
      class ErrataMail < Actions::EntryAction
        def plan(content_view, environment)
          plan_self(:content_view => content_view.id, :environment => environment.id)
        end

        def run
          ::User.current = ::User.anonymous_admin

          content_view = ::Katello::ContentView.find(input[:content_view])
          environment = ::Katello::KTEnvironment.find(input[:environment])
          users = ::User.select { |user| user.receives?(:katello_promote_errata) && user.can?(:view_content_views, content_view) }

          MailNotification[:katello_promote_errata].deliver(:users => users, :content_view => content_view, :environment  => environment) unless users.blank?
        end

        def finalize
          ::User.current = nil
        end
      end
    end
  end
end
