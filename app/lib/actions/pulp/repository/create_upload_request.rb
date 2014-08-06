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
      class CreateUploadRequest < Pulp::Abstract

        input_format do
        end

        output_format do
          param :response
          param :upload_id
        end

        def run
          output[:response] = pulp_resources.content.create_upload_request
          output[:upload_id] = output[:response][:upload_id]
        end

      end
    end
  end
end
