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
      class AddToEnvironment < Actions::Base
        def plan(content_view_version, environment)
          content_view = content_view_version.content_view
          if cve = content_view.content_view_environment(environment)
            content_view_version.content_view_environments << cve
          else
            cve = content_view.add_environment(environment, content_view_version)
            plan_action(ContentView::EnvironmentCreate, cve)
          end
          content_view_version.save!
        end
      end
    end
  end
end
