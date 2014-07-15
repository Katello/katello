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
    module Repository
      class Sync < Actions::EntryAction

        include Helpers::Presenter

        input_format do
          param :id, Integer
          param :sync_result, Hash
        end

        def plan(repo)
          sync_task = nil
          action_subject(repo)

          if repo.url.blank?
            fail _("Unable to sync %s. This repository does not have a feed url.")
          end

          sequence do
            sync_task = plan_action(Pulp::Repository::Sync, pulp_id: repo.pulp_id)
            concurrence do
              plan_action(Katello::Repository::NodeMetadataGenerate, repo, sync_task.output[:pulp_tasks])

              plan_action(ElasticSearch::Repository::IndexContent, dependency: sync_task.output[:pulp_tasks], id: repo.id)
            end
            plan_action(ElasticSearch::Reindex, repo)
            plan_action(Katello::Foreman::ContentUpdate, repo.environment, repo.content_view)
          end
          plan_self(:sync_result => sync_task.output)
        end

        def run
          output[:sync_result] = input[:sync_result]
        end

        def humanized_name
          _("Synchronize") # TODO: rename class to Synchronize and remove this method, add Sync = Synchronize
        end

        def presenter
          Helpers::Presenter::Delegated.new(self, planned_actions(Pulp::Repository::Sync))
        end

        def pulp_task_id
          pulp_action = planned_actions(Pulp::Repository::Sync).first
          pulp_action.output[:pulp_task] &&
              pulp_action.output[:pulp_task][:task_id]
        end
      end
    end
  end
end
