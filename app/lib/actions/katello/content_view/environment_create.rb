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
      class EnvironmentCreate < Actions::Base
        def plan(content_view_environment)
          content_view_environment.save!
          if ::Katello.config.use_cp
            content_view = content_view_environment.content_view
            plan_action(Candlepin::Environment::Create,
                        organization_label: content_view.organization.label,
                        cp_id:              content_view_environment.cp_id,
                        name:               content_view_environment.label,
                        description:        content_view.description)
          end
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
