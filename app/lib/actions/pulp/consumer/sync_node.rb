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
      class SyncNode < ::Actions::Pulp::AbstractAsyncTask

        input_format do
          param :uuid, String
          param :repository_ids, Array
          param :skip_content
        end

        def invoke_external_task
          if input[:repository_ids]
            pulp_extensions.consumer.update_content(input[:uuid],
                                                    'repository',
                                                    input[:repository_ids],
                                                    options)
          else
            pulp_extensions.consumer.update_content(input[:uuid], 'node',  nil, options)
          end
        end

        def options
          ret = {}
          ret[:skip_content_update] = true if input[:skip_content]
          ret
        end
      end

    end
  end
end
