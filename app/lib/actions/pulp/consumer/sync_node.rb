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
  module Pulp
    module Consumer
      class SyncNode < AbstractSyncNodeTask
        input_format do
          param :consumer_uuid, String
          param :repo_ids, Array
          param :skip_content
        end

        def invoke_external_task
          task = invoke_external_task_based_on_repos_id
          schedule_timeout(Setting['content_action_accept_timeout'])
          task
        end

        def process_timeout
          accept_timeout = Setting['pulp_sync_node_action_accept_timeout']
          finish_timeout = Setting['pulp_sync_node_action_finish_timeout']

          if pulp_state == 'waiting'
            fail _("Host did not respond within %s seconds. Is katello-agent installed and goferd running on the Host?") % accept_timeout
          elsif pulp_state == 'unknown'
            fail _("Unknown Status during sync. Is katello-agent installed and goferd running on the Host?")
          else
            if output[:sync_task_is_accepted].nil?
              output[:sync_task_is_accepted] ||= true
              schedule_timeout(finish_timeout)
            else
              fail _("Host/Node did not finish sync within %s seconds. Is katello-agent installed and goferd running on the Host?") % finish_timeout
            end
          end
        end

        def invoke_external_task_based_on_repos_id
          if input[:repo_ids]
            pulp_extensions.consumer.update_content(input[:consumer_uuid],
                                                    'repository',
                                                    input[:repo_ids],
                                                    options)
          else
            pulp_extensions.consumer.update_content(input[:consumer_uuid], 'node',  nil, options)
          end
        end

        def options
          ret = {}
          # skip_content_update means we want just to make sure only binded repositories are
          # on the node, but no content is being transferred: this way, we can
          # propagate repository deletion to the attached capsules without full sync
          ret[:skip_content_update] = true if input[:skip_content]
          ret
        end

        def poll_external_task
          result = super
          external_task && external_task.each do |pulp_task|
            if pulp_task[:state] && ['unknown'].include?(pulp_task[:state])
              fail _("Pulp sync state has become unknown.  Please check that the capsule's services are running.")
            end
          end
          result
        end

        def rescue_strategy_for_self
          # There are various reasons the syncing fails, not all of them are
          # fatal: when fail on syncing, we continue with the task ending up
          # in the warning state, but not locking further syncs
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
