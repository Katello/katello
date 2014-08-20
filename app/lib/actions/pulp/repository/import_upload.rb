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
      class ImportUpload < Pulp::AbstractAsyncTask

        input_format do
          param :pulp_id
          param :unit_type_id
          param :upload_id
        end

        def invoke_external_task
          pulp_resources.content.import_into_repo(input[:pulp_id],
                                                   input[:unit_type_id],
                                                   input[:upload_id],
                                                   {},
                                                   { unit_metadata: {} })
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

      end
    end
  end
end
