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

module Orchestrate
  module Katello
    module Pulp
      class RepositorySync < Dynflow::Action

        include Helpers::RemoteAction
        include Helpers::PulpTask

        input_format do
          param :repo_id, Integer
        end

        def run
          sync_options = {}
          sync_options[:max_speed] ||= ::Katello.config.pulp.sync_KBlimit if ::Katello.config.pulp.sync_KBlimit # set bandwidth limit
          sync_options[:num_threads] ||= ::Katello.config.pulp.sync_threads if ::Katello.config.pulp.sync_threads # set threads per sync

          pulp_tasks = pulp.repository.sync(input[:pulp_id], { override_config: sync_options })
          output[:pulp_tasks] = pulp_tasks

          # TODO: would be better polling for the whole task group to make sure we're really finished at the end
          output[:pulp_task] = pulp_tasks.find do |task|
            task['tags'].include?("pulp:action:sync")
          end
          wait_for_pulp
        end

        def run_progress
          sync_task = output[:pulp_task]
          if sync_task &&
                sync_task[:progress] &&
                sync_task[:progress][:yum_importer] &&
                (content_progress = sync_task[:progress][:yum_importer][:content])
            if content_progress[:size_total].to_i > 0
              left = content_progress[:size_left].to_f / content_progress[:size_total]
              return 1 - left
            else
              return 0.01
            end
          else
            return 0.01
          end
        end

        def run_progress_weight
          10
        end

      end
    end
  end
end
