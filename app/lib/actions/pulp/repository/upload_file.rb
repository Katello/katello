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
      class UploadFile < Pulp::Abstract

        input_format do
          param :upload_id
          param :file
        end

        def run
          File.open(input[:file], "rb") do |file|
            offset = 0
            while (chunk = file.read(upload_chunk_size))
              pulp_resources.content.upload_bits(input[:upload_id], offset, chunk)
              offset += upload_chunk_size
            end
          end
        end

        private

        def upload_chunk_size
          ::Katello.config.pulp.upload_chunk_size
        end

      end
    end
  end
end
