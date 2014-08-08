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
    module Repository
      module Presenters

        class PuppetPresenter < Helpers::Presenter::Base

          include ActionView::Helpers::NumberHelper

          def humanized_output
            if action.external_task
              humanized_details
            end
          end

          def progress
            #TODO: Add proper progress reporting
            # Requires https://bugzilla.redhat.com/show_bug.cgi?id=1128274 to be fixed
            0
          end

          private

          def humanized_details
            ret = []
            ret << _("Cancelled.") if cancelled?

            if total_count > 0
              ret << (_("Total module count: %s.") % [total_count])
            end

            if error_count > 0
              ret << n_("Failed to download %s module.", "Failed to download %s modules.",
                        error_count) % error_count
            end
            ret.join("\n")
          end

          def added_count
            task_result['added_count']
          end

          def updated_count
            task_result['updated_count']
          end

          def total_count
            task_progress_details['modules']['total_count'] || 0
          end

          def error_count
            task_result_details['error_count'] || 0
          end

          def sync_task
            action.external_task.select{ |task| task['tags'].include?("pulp:action:sync") }.first
          end

          def cancelled?
            sync_task['state'] == 'canceled'
          end

          def task_result
            sync_task['result']
          end

          def task_result_details
            task_result ? task_result['details'] : {}
          end

          def task_progress
            sync_task['progress_report']
          end

          def task_progress_details
            task_progress && task_progress['puppet_importer']
          end

        end

      end
    end
  end
end
