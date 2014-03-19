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
      class AbstractRemoveContent < Pulp::AbstractAsyncTask

        input_format do
          param :pulp_id
          param :clauses
        end

        def invoke_external_task
          pulp_extensions.repository.unassociate_units(input[:pulp_id],
                                                       criteria)
        end

        # @api override - pulp extension representing the content to remove
        # e.g. pulp.extensions.rpm
        def content_extension
          fail NotImplementedError
        end

        def criteria
          { type_ids: [content_extension.content_type], filters: {unit: input[:clauses] } }
        end

        def external_task=(external_task_data)
          super(external_task_data.except('result'))
        end

      end
    end
  end
end
