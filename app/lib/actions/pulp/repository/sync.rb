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
  module Pulp
    module Repository
      class Sync < Actions::Base

        include Helpers::RemoteAction
        include Helpers::PulpTask

        input_format do
          param :repo_id, Integer
        end

        def invoke_external_task
          sync_options = {}

          if ::Katello.config.pulp.sync_KBlimit
            # set bandwidth limit
            sync_options[:max_speed] ||= ::Katello.config.pulp.sync_KBlimit
          end
          if ::Katello.config.pulp.sync_threads
            # set threads per sync
            sync_options[:num_threads] ||= ::Katello.config.pulp.sync_threads
          end

          output[:pulp_tasks] = pulp_tasks =
              pulp_resources.repository.sync(input[:pulp_id], { override_config: sync_options })

          # TODO: would be better polling for the whole task group to make sure
          # we're really finished at the end.
          # Look at it once we have more Pulp actions rewritten so that we can find
          # a common pattern.
          pulp_tasks.find { |task| task['tags'].include?('pulp:action:sync') }
        end

        def run_progress
          content_progress = external_task &&
              external_task[:progress] &&
              external_task[:progress][:yum_importer] &&
              external_task[:progress][:yum_importer][:content]

          if content_progress && content_progress[:size_total].to_i > 0
            left = content_progress[:size_left].to_f / content_progress[:size_total]
            1 - left
          else
            0.01
          end
        end

        def run_progress_weight
          10
        end

      end
    end
  end
end
