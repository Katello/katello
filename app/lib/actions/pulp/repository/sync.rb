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
      class Sync < Pulp::AsyncTask

        include Helpers::Presenter

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
          presenter.progress
        end

        def run_progress_weight
          10
        end

        def presenter
          Sync::Presenter.new(self)
        end

        class Presenter < Helpers::Presenter::Base

          # TODO: in Rails 4.0, the logic is possible to use from ActiveSupport
          include ActionView::Helpers::NumberHelper

          def humanized_output
            if action.external_task
              humanized_details
            end
          end

          def progress
            if action.external_task && size_total > 0
              size_done.to_f / size_total
            else
              0.01
            end
          end

          private

          def humanized_details
            ret = []
            if content_details && content_details[:state] != 'NOT_STARTED'
              if items_total > 0
                ret << (_("New packages: %s (%s)") % [count_summary, size_summary])
              else
                ret << _("No new packages")
              end
            end
            if metadata_details  && metadata_details[:state] == 'IN_PROGRESS'
              ret << _("Processing metadata")
            end
            return ret.join("\n")
          end

          def count_summary
            if content_details[:state] == "IN_PROGRESS"
              "#{items_done}/#{items_total}"
            else
              items_done
            end
          end

          def size_summary
            if content_details[:state] == "IN_PROGRESS"
              "#{number_to_human_size(size_done)}/#{number_to_human_size(size_total)}"
            else
              number_to_human_size(size_total)
            end
          end

          def task_result
            action.external_task[:result]
          end

          def task_result_details
            task_result && task_result[:details]
          end

          def task_progress
            action.external_task[:progress]
          end

          def task_progress_details
            task_progress && task_progress[:yum_importer]
          end

          def task_details
            task_result_details || task_progress_details
          end

          def content_details
            task_details && task_details[:content]
          end

          def metadata_details
            task_details && task_details[:metadata]
          end

          def items_done
            items_total - content_details[:items_left]
          end

          def items_total
            content_details[:items_total].to_i
          end

          def size_done
            size_total - content_details[:size_left]
          end

          def size_total
            (content_details && content_details[:size_total]).to_i
          end

        end

      end
    end
  end
end
