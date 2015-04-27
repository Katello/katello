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
      class ManageBoundRepositories < ::Actions::EntryAction
        # @param capsule_content [::Katello::CapsuleContent]
        # @param pulp_repo [::Katello::Glue::Pulp::Repo]
        def plan(capsule_content)
          fail _("Action not allowed for the default capsule.") if capsule_content.default_capsule?

          needed_repo_ids = capsule_content.pulp_repos.map(&:pulp_id)
          current_repo_ids = capsule_content.consumer.bound_node_repos
          to_add = needed_repo_ids - current_repo_ids
          to_remove = current_repo_ids - needed_repo_ids

          to_add.each do |pulp_id|
            plan_action(Pulp::Consumer::BindNodeDistributor,
                        consumer_uuid: capsule_content.consumer_uuid,
                        repo_id: pulp_id,
                        bind_options: bind_options)
          end

          to_remove.each do |pulp_id|
            plan_action(Pulp::Consumer::UnbindNodeDistributor,
                                  consumer_uuid: capsule_content.consumer_uuid,
                                  repo_id: pulp_id)
          end
        end

        private

        def bind_options
          { notify_agent: false, binding_config: { strategy: 'mirror' } }
        end
      end
    end
  end
end
