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
      class RemoveRepository < ::Actions::EntryAction
        # @param capsule_content [::Katello::CapsuleContent]
        # @param pulp_repo [::Katello::Glue::Pulp::Repo]
        def plan(capsule_content, pulp_repo)
          fail _("Action not allowed for the default capsule.") if capsule_content.default_capsule?

          distributor = pulp_repo.find_node_distributor
          if distributor
            plan_action(Pulp::Consumer::UnbindNodeDistributor,
                                  consumer_uuid: capsule_content.consumer_uuid,
                                  repo_id: pulp_repo.pulp_id)
          else
            Rails.logger.error("Could not find node distributor for repository %s" % pulp_repo.pulp_id)
          end
        end
      end
    end
  end
end
