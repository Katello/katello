#
# Copyright 2013 Red Hat, Inc.
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
    module Repository
      class CloneToVersion < Actions::Base

        def plan(repository, content_view_version)
          content_view = content_view_version.content_view
          filters = content_view.filters.applicable(repository)
          clone = repository.build_clone(content_view: content_view,
                                         version: content_view_version)
          sequence do
            plan_action(Repository::Create, clone, true)
            plan_action(Repository::CloneContent, repository, clone, filters)
          end
        end

      end
    end
  end
end
