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
    module ContentViewPuppetEnvironment
      class CreateForVersion < Actions::Base
        # allows accessing the build object from the superior action
        attr_accessor :new_puppet_environment

        def plan(content_view_version)
          content_view = content_view_version.content_view
          modules_by_repoid = content_view.computed_module_ids_by_repoid

          self.new_puppet_environment = content_view.build_puppet_env(:version => content_view_version)

          sequence do
            plan_action(ContentViewPuppetEnvironment::Create, new_puppet_environment, true)
            plan_action(ContentViewPuppetEnvironment::CloneContent, new_puppet_environment, modules_by_repoid)
          end
        end
      end
    end
  end
end
