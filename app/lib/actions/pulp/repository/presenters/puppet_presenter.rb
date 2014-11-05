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

        class PuppetPresenter < AbstractSyncPresenter

          def progress
            total_count == 0 ? 0 : finished_count.to_f / total_count
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

          def finished_count
            task_result['finished_count']
          end

          def total_count
            task_progress_details['modules']['total_count'] || 0
          end

          def error_count
            return 0 if !task_result_details || !task_result_details['error_count']
            task_result_details['error_count']
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
