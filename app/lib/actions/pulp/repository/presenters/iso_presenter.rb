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

        class IsoPresenter < Helpers::Presenter::Base
          include ActionView::Helpers::NumberHelper

          def humanized_output
            if action.external_task
              humanized_details
            end
          end

          def progress
            total_bytes == 0 ? 0.01 : finished_bytes.to_f / total_bytes
          end

          private

          def humanized_details
            ret = []
            ret << _("Cancelled.") if cancelled?
            ret << _("New ISOs: %s") % num_isos
            ret.join("\n")
          end

          def sync_task
            action.external_task.select{ |task| task['tags'].include?("pulp:action:sync") }.first
          end

          def cancelled?
            sync_task['state'] == 'canceled'
          end

          def num_isos
            task_progress_details['num_isos'] || 0
          end

          def total_bytes
            task_progress_details['total_bytes'] || 0
          end

          def finished_bytes
            task_progress_details['finished_bytes'] || 0
          end

          def task_progress_details
            task_progress && task_progress['iso_importer']
          end

          def task_progress
            sync_task['progress_report']
          end
        end
      end
    end
  end
end
