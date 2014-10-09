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

        class AbstractSyncPresenter < Helpers::Presenter::Base
          # TODO: in Rails 4.0, the logic is possible to use from ActiveSupport
          include ActionView::Helpers::NumberHelper

          def humanized_output
            if action.external_task
              humanized_details
            end
          end

          private

          def humanized_details
            fail NotImplementedError
          end

          def sync_task
            tasks = action.external_task.select do |task|
              if task.key? 'tags'
                task['tags'].include?("pulp:action:sync")
              else
                # workaround for https://bugzilla.redhat.com/show_bug.cgi?id=1131537
                # as the sync plan tasks don't have tags in pulp
                task['result'] &&
                    task['result']['importer_type_id'].to_s =~ /_importer$/
              end
            end
            tasks.first
          end

          def cancelled?
            sync_task['state'] == 'canceled'
          end

          def task_result
            sync_task['result']
          end

          def task_result_details
            task_result && task_result['details']
          end

        end
      end
    end
  end
end
