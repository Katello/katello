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
      class AbstractSyncNodeTask <  ::Actions::Pulp::AbstractAsyncTask

        private

        def external_task=(external_task_data)
          external_task_data = [external_task_data] if external_task_data.is_a?(Hash)
          output[:pulp_tasks] = external_task_data.reject { |task| task['task_id'].nil? }

          output[:pulp_tasks].each do |pulp_task|
            if pulp_task[:result] && pulp_task[:result].key?(:succeeded) && pulp_task[:result][:succeeded] == false
              fail StandardError, _("Pulp task error.  Refer to task for more details.")
            end
          end
          super(external_task_data)
        end

      end
    end
  end
end
