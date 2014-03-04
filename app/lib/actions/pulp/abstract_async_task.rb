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
    class AbstractAsyncTask < Pulp::Abstract
      include Dynflow::Action::Polling

      def done?
        !!external_task[:finish_time]
      end

      def external_task
        output[:pulp_task]
      end

      private

      def external_task=(external_task_data)
        output[:pulp_task] = external_task_data
        if output[:pulp_task][:state] == 'error'
          message = if output[:pulp_task][:exception]
                      Array(output[:pulp_task][:exception]).join('; ')
                    else
                      "Pulp task error"
                    end
          error! message
        end
      end

      def poll_external_task
        task_resource.poll(external_task[:task_id])
      end

      def task_resource
        ::Katello.pulp_server.resources.task
      end
    end
  end
end
