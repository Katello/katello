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
      class AbstractCopyContent < Pulp::AbstractAsyncTask

        input_format do
          param :source_pulp_id
          param :target_pulp_id
          param :clauses
        end

        # @api override - pulp extension representing the content type to copy
        def content_extension
          fail NotImplementedError
        end

        def invoke_external_task
          content_extension.copy(input[:source_pulp_id],
                                 input[:target_pulp_id],
                                 criteria)
        end

        def criteria
          if input[:clauses]
            { filters: {:unit => input[:clauses] } }
          else
            {}
          end
        end

        def external_task=(external_task_data)
          external_task_data = [external_task_data] if external_task_data.is_a?(Hash)
          super(external_task_data.map{ |task| task.except('result')})
        end

      end
    end
  end
end
