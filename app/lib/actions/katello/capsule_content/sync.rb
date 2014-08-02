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
    module CapsuleContent
      class Sync < ::Actions::EntryAction

        def plan(capsule_content, environment = nil)
          fail _("Action not allowed for the default capsule.") if capsule_content.default_capsule?

          if environment && !capsule_content.lifecycle_environments.include?(environment)
            fail _("Lifecycle environment '%{environment}' is not attached to this capsule.") % { :environment => environment.name }
          end

          repository_ids = if environment
                             capsule_content.pulp_repos(environment).map(&:pulp_id)
                           end

          plan_action(Pulp::Consumer::SyncNode,
                      consumer_uuid: capsule_content.consumer_uuid,
                      repo_ids: repository_ids)
        end

      end
    end
  end
end
