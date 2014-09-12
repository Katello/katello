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
        def plan(content_view)
          action_subject(content_view)
          content_view.check_ready_to_destroy!

          sequence do
            concurrence do
              content_view.content_view_versions.each do |version|
                plan_action(ContentViewVersion::Destroy, version)
              end
            end

            content_view.destroy!
          end
        end

        def humanized_name
          _("Delete")
        end
      end
    end
  end
end
